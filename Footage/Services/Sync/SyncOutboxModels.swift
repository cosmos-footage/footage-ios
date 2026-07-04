//
//  SyncOutboxModels.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct IdempotencyKey: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

extension IdempotencyKey {
    static func make(
        installationId: InstallationID,
        syncBatchId: SyncBatchID,
        schemaVersion: Int
    ) -> IdempotencyKey {
        IdempotencyKey(rawValue: "\(installationId.rawValue):\(syncBatchId.rawValue):schema_\(schemaVersion)")
    }
}

enum SyncOutboxItemType: String, Codable, Equatable {
    case routePoints
    case recordingSession
    case daySummary
    case mediaMetadata
}

enum SyncOutboxItemStatus: String, Codable, Equatable {
    case pending
    case syncing
    case synced
    case failed
}

struct SyncBatchConfiguration: Codable, Equatable {
    var schemaVersion: Int
    var maxPointsPerBatch: Int

    init(schemaVersion: Int = 1, maxPointsPerBatch: Int = 500) {
        self.schemaVersion = schemaVersion
        self.maxPointsPerBatch = max(1, maxPointsPerBatch)
    }
}

struct SyncBatchDraft: Codable, Equatable {
    var syncBatchId: SyncBatchID
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var installationId: InstallationID
    var schemaVersion: Int
    var idempotencyKey: IdempotencyKey
    var itemIds: [String]
    var routePointCount: Int
    var createdAt: Date

    init(
        syncBatchId: SyncBatchID = .generate(),
        ownerId: OwnerID? = nil,
        deviceId: DeviceID? = nil,
        installationId: InstallationID,
        schemaVersion: Int = 1,
        itemIds: [String] = [],
        routePointCount: Int = 0,
        createdAt: Date = Date()
    ) {
        self.syncBatchId = syncBatchId
        self.ownerId = ownerId
        self.deviceId = deviceId
        self.installationId = installationId
        self.schemaVersion = schemaVersion
        self.idempotencyKey = IdempotencyKey.make(
            installationId: installationId,
            syncBatchId: syncBatchId,
            schemaVersion: schemaVersion
        )
        self.itemIds = itemIds
        self.routePointCount = routePointCount
        self.createdAt = createdAt
    }
}

struct SyncOutboxPayload: Codable, Equatable {
    var localDate: String?
    var recordingIds: [RecordingID]
    var routePointCount: Int
    var contentType: String
    var isCompressed: Bool
    var ndjson: String?
    var localPayloadFilePath: String?
    var payloadContentLength: Int?

    init(
        localDate: String? = nil,
        recordingIds: [RecordingID] = [],
        routePointCount: Int = 0,
        contentType: String = "application/x-ndjson",
        isCompressed: Bool = false,
        ndjson: String? = nil,
        localPayloadFilePath: String? = nil,
        payloadContentLength: Int? = nil
    ) {
        self.localDate = localDate
        self.recordingIds = recordingIds
        self.routePointCount = routePointCount
        self.contentType = contentType
        self.isCompressed = isCompressed
        self.ndjson = ndjson
        self.localPayloadFilePath = localPayloadFilePath
        self.payloadContentLength = payloadContentLength
    }
}

struct SyncOutboxItem: Codable, Equatable {
    var id: String
    var syncBatch: SyncBatchDraft
    var type: SyncOutboxItemType
    var status: SyncOutboxItemStatus
    var payload: SyncOutboxPayload
    var attemptCount: Int
    var createdAt: Date
    var updatedAt: Date
    var lastErrorMessage: String?

    init(
        id: String? = nil,
        syncBatch: SyncBatchDraft,
        type: SyncOutboxItemType,
        status: SyncOutboxItemStatus = .pending,
        payload: SyncOutboxPayload,
        attemptCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastErrorMessage: String? = nil
    ) {
        let itemId = id ?? "\(syncBatch.syncBatchId.rawValue):\(type.rawValue)"
        var batch = syncBatch
        if !batch.itemIds.contains(itemId) {
            batch.itemIds.append(itemId)
        }

        self.id = itemId
        self.syncBatch = batch
        self.type = type
        self.status = status
        self.payload = payload
        self.attemptCount = attemptCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastErrorMessage = lastErrorMessage
    }
}

struct LocalBackupStatus: Codable, Equatable {
    var pendingCount: Int
    var failedCount: Int
    var lastPreparedAt: Date?
    var lastError: String?
}
