//
//  RestoreService.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum RestoreServiceError: Error {
    case restoreDisabled
    case missingIdentity
    case missingBearerToken
}

final class RestoreService {
    private let configuration: CloudBackupConfiguration
    private let apiClient: CloudBackupAPIClientProtocol
    private let identityRepository: DeviceIdentityRepository
    private let parser: RoutePointRestoreParser
    private let importRepository: RestoreImportRepository

    private(set) var status: RestoreStatus = .idle

    init(
        configuration: CloudBackupConfiguration = CloudBackupConfiguration(),
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        parser: RoutePointRestoreParser = RoutePointRestoreParser(),
        importRepository: RestoreImportRepository = LocalRestoreImportRepository()
    ) {
        self.configuration = configuration
        self.apiClient = apiClient ?? CloudBackupAPIClient(configuration: configuration)
        self.identityRepository = identityRepository
        self.parser = parser
        self.importRepository = importRepository
    }

    func requestRestoreManifest(
        ownerId: OwnerID,
        deviceId: DeviceID,
        bearerToken: String,
        since: Date? = nil,
        completion: @escaping (Result<RestoreManifestResponse, Error>) -> Void
    ) {
        guard configuration.isCloudBackupEnabled else {
            completion(.failure(RestoreServiceError.restoreDisabled))
            return
        }

        status = .fetchingManifest
        CloudBackupLogger.info("restore manifest requested")
        apiClient.requestRestoreManifest(
            ownerId: ownerId,
            deviceId: deviceId,
            since: since,
            bearerToken: bearerToken
        ) { [weak self] result in
            self?.status = result.isSuccess ? .downloading : .failed
            completion(result)
        }
    }

    func previewRestoreFromCurrentIdentity(
        bearerToken: String?,
        since: Date? = nil,
        conflictPolicy: RestoreConflictPolicy = .skipExisting,
        completion: @escaping (Result<RestorePreview, Error>) -> Void
    ) {
        guard configuration.isCloudBackupEnabled else {
            completion(.failure(RestoreServiceError.restoreDisabled))
            return
        }

        guard let ownerId = identityRepository.ownerId(),
              let deviceId = identityRepository.deviceId() else {
            completion(.failure(RestoreServiceError.missingIdentity))
            return
        }

        guard let bearerToken = bearerToken, !bearerToken.isEmpty else {
            completion(.failure(RestoreServiceError.missingBearerToken))
            return
        }

        requestRestoreManifest(
            ownerId: ownerId,
            deviceId: deviceId,
            bearerToken: bearerToken,
            since: since
        ) { [weak self] manifestResult in
            switch manifestResult {
            case .success(let manifest):
                self?.downloadAndPreview(
                    manifest: manifest,
                    conflictPolicy: conflictPolicy,
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func previewLocalManifest(
        _ manifest: RestoreManifestResponse,
        routeObjectData: [Data],
        conflictPolicy: RestoreConflictPolicy = .skipExisting
    ) -> Result<RestorePreview, Error> {
        status = .parsing

        do {
            let points = try routeObjectData.flatMap { try parser.parse(data: $0) }
            let size = routeObjectData.reduce(0) { $0 + $1.count }
            let plan = importRepository.previewImport(
                manifest: manifest,
                routePoints: points,
                estimatedImportSizeBytes: size,
                conflictPolicy: conflictPolicy
            )
            status = .readyToImport
            return .success(RestorePreview(manifest: manifest, routePoints: points, importPlan: plan))
        } catch {
            status = .failed
            return .failure(error)
        }
    }

    private func downloadAndPreview(
        manifest: RestoreManifestResponse,
        conflictPolicy: RestoreConflictPolicy,
        completion: @escaping (Result<RestorePreview, Error>) -> Void
    ) {
        let routeObjects = manifest.recordings
            .flatMap(\.objects)
            .filter { $0.objectType == SyncOutboxItemType.routePoints.rawValue }

        download(routeObjects: routeObjects, downloadedData: []) { [weak self] result in
            switch result {
            case .success(let routeObjectData):
                completion(self?.previewLocalManifest(
                    manifest,
                    routeObjectData: routeObjectData,
                    conflictPolicy: conflictPolicy
                ) ?? .failure(RestoreServiceError.restoreDisabled))
            case .failure(let error):
                self?.status = .failed
                completion(.failure(error))
            }
        }
    }

    private func download(
        routeObjects: [RestoreManifestResponse.Recording.DownloadObject],
        downloadedData: [Data],
        completion: @escaping (Result<[Data], Error>) -> Void
    ) {
        guard let object = routeObjects.first else {
            completion(.success(downloadedData))
            return
        }

        status = .downloading
        apiClient.downloadData(from: object.downloadUrl) { [weak self] result in
            switch result {
            case .success(let data):
                self?.download(
                    routeObjects: Array(routeObjects.dropFirst()),
                    downloadedData: downloadedData + [data],
                    completion: completion
                )
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}
