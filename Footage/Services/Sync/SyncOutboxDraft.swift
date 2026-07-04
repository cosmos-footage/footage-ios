//
//  SyncOutboxDraft.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum SyncStatus: String, Codable, Equatable {
    case localOnly
    case pending
    case syncing
    case synced
    case failed
}

struct SyncOutboxDraft: Codable, Equatable {
    var syncBatchId: SyncBatchID
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var installationId: InstallationID
    var recordingIds: [RecordingID]
    var status: SyncStatus
    var attemptCount: Int
    var createdAt: Date
    var updatedAt: Date
    var lastErrorMessage: String?

    init(
        syncBatchId: SyncBatchID = .generate(),
        ownerId: OwnerID? = nil,
        deviceId: DeviceID? = nil,
        installationId: InstallationID,
        recordingIds: [RecordingID],
        status: SyncStatus = .pending,
        attemptCount: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        lastErrorMessage: String? = nil
    ) {
        self.syncBatchId = syncBatchId
        self.ownerId = ownerId
        self.deviceId = deviceId
        self.installationId = installationId
        self.recordingIds = recordingIds
        self.status = status
        self.attemptCount = attemptCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.lastErrorMessage = lastErrorMessage
    }
}
