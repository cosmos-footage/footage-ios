//
//  RestoreModels.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum RestoreConflictPolicy: String, Codable, Equatable {
    case skipExisting
    case keepBoth
    case replaceOnlyIfSameRecordingIdAndExplicitlyConfirmed
}

enum RestoreStatus: String, Codable, Equatable {
    case idle
    case fetchingManifest
    case downloading
    case parsing
    case readyToImport
    case importing
    case completed
    case failed
}

struct RestoreImportPlan: Codable, Equatable {
    var ownerId: OwnerID
    var sourceDeviceId: DeviceID?
    var recordingCount: Int
    var routePointCount: Int
    var daySummaryCount: Int
    var mediaAssetCount: Int
    var duplicateCandidateCount: Int
    var estimatedImportSizeBytes: Int
    var warnings: [String]
    var canImport: Bool
    var requiresUserConfirmation: Bool
    var conflictPolicy: RestoreConflictPolicy

    init(
        ownerId: OwnerID,
        sourceDeviceId: DeviceID?,
        recordingCount: Int,
        routePointCount: Int,
        daySummaryCount: Int = 0,
        mediaAssetCount: Int = 0,
        duplicateCandidateCount: Int = 0,
        estimatedImportSizeBytes: Int = 0,
        warnings: [String] = [],
        canImport: Bool = false,
        requiresUserConfirmation: Bool = true,
        conflictPolicy: RestoreConflictPolicy = .skipExisting
    ) {
        self.ownerId = ownerId
        self.sourceDeviceId = sourceDeviceId
        self.recordingCount = recordingCount
        self.routePointCount = routePointCount
        self.daySummaryCount = daySummaryCount
        self.mediaAssetCount = mediaAssetCount
        self.duplicateCandidateCount = duplicateCandidateCount
        self.estimatedImportSizeBytes = estimatedImportSizeBytes
        self.warnings = warnings
        self.canImport = canImport
        self.requiresUserConfirmation = requiresUserConfirmation
        self.conflictPolicy = conflictPolicy
    }
}

struct RestorePreview {
    var manifest: RestoreManifestResponse
    var routePoints: [RoutePointDraft]
    var importPlan: RestoreImportPlan
}

struct RestoreImportResult: Codable, Equatable {
    var importedRecordingCount: Int
    var importedRoutePointCount: Int
    var skippedDuplicateCount: Int
    var warnings: [String]
}
