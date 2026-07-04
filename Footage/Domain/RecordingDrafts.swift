//
//  RecordingDrafts.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct RecordingSessionDraft: Codable, Equatable {
    var recordingId: RecordingID
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var installationId: InstallationID
    var localDate: String
    var startedAt: Date
    var endedAt: Date?
    var distanceMeters: Double
    var primaryColor: String?
    var syncStatus: SyncStatus

    init(
        recordingId: RecordingID = .generate(),
        ownerId: OwnerID? = nil,
        deviceId: DeviceID? = nil,
        installationId: InstallationID,
        localDate: String,
        startedAt: Date,
        endedAt: Date? = nil,
        distanceMeters: Double = 0,
        primaryColor: String? = nil,
        syncStatus: SyncStatus = .localOnly
    ) {
        self.recordingId = recordingId
        self.ownerId = ownerId
        self.deviceId = deviceId
        self.installationId = installationId
        self.localDate = localDate
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.distanceMeters = distanceMeters
        self.primaryColor = primaryColor
        self.syncStatus = syncStatus
    }
}

struct RoutePointDraft: Codable, Equatable {
    var pointId: PointID
    var recordingId: RecordingID
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var horizontalAccuracy: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?
    var color: String
    var setAsStart: Bool
    var sequence: Int
    var syncStatus: SyncStatus
}

struct DaySummaryDraft: Codable, Equatable {
    var localDate: String
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var distanceMeters: Double
    var recordingCount: Int
    var pointCount: Int
    var previewAssetId: String?
    var syncStatus: SyncStatus
}
