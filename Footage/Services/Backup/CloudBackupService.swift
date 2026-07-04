//
//  CloudBackupService.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import CryptoKit
import Foundation
import UIKit

enum CloudBackupServiceError: Error {
    case cloudBackupDisabled
    case developmentUploadDisabled
    case missingBearerToken
    case missingOwnerOrDevice
    case missingPayload
    case missingRecordingId
    case unsupportedItemType(SyncOutboxItemType)
}

final class CloudBackupService {
    private let configuration: CloudBackupConfiguration
    private let apiClient: CloudBackupAPIClientProtocol
    private let identityRepository: DeviceIdentityRepository
    private let syncOutboxRepository: SyncOutboxRepository
    private let tokenStore: CloudBackupTokenStore

    init(
        configuration: CloudBackupConfiguration = CloudBackupConfiguration(),
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        syncOutboxRepository: SyncOutboxRepository = LocalSyncOutboxRepository(),
        tokenStore: CloudBackupTokenStore = KeychainCloudBackupTokenStore()
    ) {
        self.configuration = configuration
        self.apiClient = apiClient ?? CloudBackupAPIClient(configuration: configuration)
        self.identityRepository = identityRepository
        self.syncOutboxRepository = syncOutboxRepository
        self.tokenStore = tokenStore
    }

    func bootstrapInstallation(completion: @escaping (Result<BootstrapResponse, Error>) -> Void) {
        guard configuration.isCloudBackupEnabled else {
            completion(.failure(CloudBackupServiceError.cloudBackupDisabled))
            return
        }

        let request = BootstrapRequest(
            installationId: identityRepository.installationId().rawValue,
            appBundleId: Bundle.main.bundleIdentifier ?? "co.el.footage",
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            platform: "ios",
            device: BootstrapRequest.Device(
                vendorIdHash: nil,
                model: UIDevice.current.model,
                osVersion: UIDevice.current.systemVersion
            ),
            capabilities: BootstrapRequest.Capabilities(
                schemaVersion: configuration.schemaVersion,
                supportsGzip: false,
                supportsRestore: true
            )
        )

        CloudBackupLogger.info("bootstrap requested")
        apiClient.bootstrapInstallation(request) { [identityRepository, tokenStore] result in
            switch result {
            case .success(let response):
                do {
                    identityRepository.save(
                        ownerId: OwnerID(rawValue: response.ownerId),
                        deviceId: DeviceID(rawValue: response.deviceId)
                    )
                    try tokenStore.saveAnonymousDeviceToken(
                        response.anonymousDeviceToken,
                        expiresAt: response.tokenExpiresAt
                    )
                    CloudBackupLogger.info("bootstrap succeeded")
                    completion(.success(response))
                } catch {
                    CloudBackupLogger.failure(operation: "persist bootstrap identity")
                    completion(.failure(error))
                }
            case .failure:
                CloudBackupLogger.failure(operation: "bootstrap")
                completion(result)
            }
        }
    }

    func runPendingBackup(
        bearerToken: String?,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard configuration.isCloudBackupEnabled else {
            completion(.failure(CloudBackupServiceError.cloudBackupDisabled))
            return
        }

        guard configuration.isDevelopmentUploadEnabled else {
            completion(.failure(CloudBackupServiceError.developmentUploadDisabled))
            return
        }

        guard let bearerToken = bearerToken, !bearerToken.isEmpty else {
            completion(.failure(CloudBackupServiceError.missingBearerToken))
            return
        }

        let pendingItems = syncOutboxRepository.pendingItems()
        process(items: pendingItems, bearerToken: bearerToken, syncedCount: 0, completion: completion)
    }

    private func process(
        items: [SyncOutboxItem],
        bearerToken: String,
        syncedCount: Int,
        completion: @escaping (Result<Int, Error>) -> Void
    ) {
        guard let item = items.first else {
            completion(.success(syncedCount))
            return
        }

        process(item: item, bearerToken: bearerToken) { [weak self] result in
            let remainingItems = Array(items.dropFirst())
            switch result {
            case .success:
                self?.process(
                    items: remainingItems,
                    bearerToken: bearerToken,
                    syncedCount: syncedCount + 1,
                    completion: completion
                )
            case .failure:
                self?.process(
                    items: remainingItems,
                    bearerToken: bearerToken,
                    syncedCount: syncedCount,
                    completion: completion
                )
            }
        }
    }

    private func process(
        item: SyncOutboxItem,
        bearerToken: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            try syncOutboxRepository.markSyncing(itemId: item.id)

            guard item.type == .routePoints else {
                throw CloudBackupServiceError.unsupportedItemType(item.type)
            }

            guard let ownerId = item.syncBatch.ownerId?.rawValue,
                  let deviceId = item.syncBatch.deviceId?.rawValue else {
                throw CloudBackupServiceError.missingOwnerOrDevice
            }

            guard let ndjson = item.payload.ndjson,
                  let data = ndjson.data(using: .utf8) else {
                throw CloudBackupServiceError.missingPayload
            }

            guard let recordingId = item.payload.recordingIds.first?.rawValue else {
                throw CloudBackupServiceError.missingRecordingId
            }

            let checksum = checksumSha256Base64(for: data)
            let presignRequest = PresignUploadRequest(
                ownerId: ownerId,
                deviceId: deviceId,
                recordingId: recordingId,
                syncBatchId: item.syncBatch.syncBatchId.rawValue,
                objectType: item.type.rawValue,
                contentType: item.payload.contentType,
                contentLength: data.count,
                checksumSha256: checksum
            )

            CloudBackupLogger.info("presign requested")
            apiClient.requestPresignedUpload(
                presignRequest,
                bearerToken: bearerToken,
                idempotencyKey: IdempotencyKey(rawValue: "\(item.syncBatch.idempotencyKey.rawValue):presign")
            ) { [weak self] presignResult in
                self?.handlePresignResult(
                    presignResult,
                    item: item,
                    ownerId: ownerId,
                    deviceId: deviceId,
                    recordingId: recordingId,
                    checksum: checksum,
                    data: data,
                    bearerToken: bearerToken,
                    completion: completion
                )
            }
        } catch {
            fail(itemId: item.id, error: error, completion: completion)
        }
    }

    private func handlePresignResult(
        _ result: Result<PresignUploadResponse, Error>,
        item: SyncOutboxItem,
        ownerId: String,
        deviceId: String,
        recordingId: String,
        checksum: String,
        data: Data,
        bearerToken: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        switch result {
        case .success(let presignResponse):
            CloudBackupLogger.info("presign succeeded")
            apiClient.uploadDataToPresignedURL(
                data: data,
                response: presignResponse,
                contentType: item.payload.contentType
            ) { [weak self] uploadResult in
                self?.handleUploadResult(
                    uploadResult,
                    presignResponse: presignResponse,
                    item: item,
                    ownerId: ownerId,
                    deviceId: deviceId,
                    recordingId: recordingId,
                    checksum: checksum,
                    dataLength: data.count,
                    bearerToken: bearerToken,
                    completion: completion
                )
            }
        case .failure(let error):
            fail(itemId: item.id, error: error, completion: completion)
        }
    }

    private func handleUploadResult(
        _ result: Result<Void, Error>,
        presignResponse: PresignUploadResponse,
        item: SyncOutboxItem,
        ownerId: String,
        deviceId: String,
        recordingId: String,
        checksum: String,
        dataLength: Int,
        bearerToken: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        switch result {
        case .success:
            CloudBackupLogger.info("presigned upload succeeded")
            let completeRequest = UploadCompleteRequest(
                uploadId: presignResponse.uploadId,
                ownerId: ownerId,
                deviceId: deviceId,
                recordingId: recordingId,
                syncBatchId: item.syncBatch.syncBatchId.rawValue,
                objectKey: presignResponse.objectKey,
                checksumSha256: checksum,
                contentLength: dataLength
            )
            apiClient.completeUpload(
                completeRequest,
                bearerToken: bearerToken,
                idempotencyKey: IdempotencyKey(rawValue: "\(item.syncBatch.idempotencyKey.rawValue):complete")
            ) { [weak self] completeResult in
                self?.handleCompleteResult(
                    completeResult,
                    item: item,
                    ownerId: ownerId,
                    deviceId: deviceId,
                    recordingId: recordingId,
                    objectKey: presignResponse.objectKey,
                    checksum: checksum,
                    dataLength: dataLength,
                    bearerToken: bearerToken,
                    completion: completion
                )
            }
        case .failure(let error):
            fail(itemId: item.id, error: error, completion: completion)
        }
    }

    private func handleCompleteResult(
        _ result: Result<UploadCompleteResponse, Error>,
        item: SyncOutboxItem,
        ownerId: String,
        deviceId: String,
        recordingId: String,
        objectKey: String,
        checksum: String,
        dataLength: Int,
        bearerToken: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        switch result {
        case .success:
            CloudBackupLogger.info("upload complete succeeded")
            let syncRequest = SyncBatchRequest(
                ownerId: ownerId,
                deviceId: deviceId,
                installationId: item.syncBatch.installationId.rawValue,
                syncBatchId: item.syncBatch.syncBatchId.rawValue,
                schemaVersion: item.syncBatch.schemaVersion,
                startedAt: item.createdAt,
                completedAt: Date(),
                recordings: [
                    SyncBatchRequest.Recording(
                        recordingId: recordingId,
                        localDate: item.payload.localDate ?? "",
                        pointCount: item.payload.routePointCount,
                        distanceMeters: nil,
                        objects: [
                            SyncBatchRequest.Recording.UploadedObject(
                                objectType: item.type.rawValue,
                                objectKey: objectKey,
                                checksumSha256: checksum,
                                contentLength: dataLength
                            )
                        ]
                    )
                ]
            )
            apiClient.registerSyncBatch(
                syncRequest,
                bearerToken: bearerToken,
                idempotencyKey: item.syncBatch.idempotencyKey
            ) { [weak self] syncResult in
                self?.handleSyncBatchResult(syncResult, itemId: item.id, completion: completion)
            }
        case .failure(let error):
            fail(itemId: item.id, error: error, completion: completion)
        }
    }

    private func handleSyncBatchResult(
        _ result: Result<SyncBatchResponse, Error>,
        itemId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        switch result {
        case .success:
            do {
                try syncOutboxRepository.markSynced(itemId: itemId)
                CloudBackupLogger.info("sync batch accepted")
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            fail(itemId: itemId, error: error, completion: completion)
        }
    }

    private func fail(
        itemId: String,
        error: Error,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        do {
            try syncOutboxRepository.markFailed(itemId: itemId, errorMessage: String(describing: type(of: error)))
        } catch {
            CloudBackupLogger.failure(operation: "mark failed")
        }
        CloudBackupLogger.failure(operation: "backup item")
        completion(.failure(error))
    }

    private func checksumSha256Base64(for data: Data) -> String {
        Data(SHA256.hash(data: data)).base64EncodedString()
    }
}
