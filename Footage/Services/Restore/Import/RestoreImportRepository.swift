//
//  RestoreImportRepository.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

protocol RestoreImportRepository {
    func previewImport(
        manifest: RestoreManifestResponse,
        routePoints: [RoutePointDraft],
        estimatedImportSizeBytes: Int,
        conflictPolicy: RestoreConflictPolicy
    ) -> RestoreImportPlan

    func importData(
        plan: RestoreImportPlan,
        routePoints: [RoutePointDraft],
        conflictPolicy: RestoreConflictPolicy,
        explicitlyConfirmed: Bool
    ) throws -> RestoreImportResult
}

enum RestoreImportRepositoryError: Error {
    case importNotImplemented
    case destructivePolicyNotAllowed
    case explicitConfirmationRequired
}

struct LocalRestoreImportRepository: RestoreImportRepository {
    private let duplicateDetector: RestoreDuplicateDetector

    init(duplicateDetector: RestoreDuplicateDetector = RestoreDuplicateDetector()) {
        self.duplicateDetector = duplicateDetector
    }

    func previewImport(
        manifest: RestoreManifestResponse,
        routePoints: [RoutePointDraft],
        estimatedImportSizeBytes: Int,
        conflictPolicy: RestoreConflictPolicy = .skipExisting
    ) -> RestoreImportPlan {
        let sourceDeviceId = manifest.recordings.first.map { DeviceID(rawValue: $0.deviceId) }
        let duplicateCount = duplicateDetector.duplicateCandidateCount(
            incomingPoints: routePoints,
            existingPointKeys: []
        )
        var warnings = ["Restore import is preview-only; no Realm data is mutated in this phase."]

        if conflictPolicy == .replaceOnlyIfSameRecordingIdAndExplicitlyConfirmed {
            warnings.append("Destructive replacement is disabled until an explicit import migration is implemented.")
        }

        return RestoreImportPlan(
            ownerId: OwnerID(rawValue: manifest.ownerId),
            sourceDeviceId: sourceDeviceId,
            recordingCount: manifest.recordings.count,
            routePointCount: routePoints.count,
            duplicateCandidateCount: duplicateCount,
            estimatedImportSizeBytes: estimatedImportSizeBytes,
            warnings: warnings,
            canImport: false,
            requiresUserConfirmation: true,
            conflictPolicy: conflictPolicy
        )
    }

    func importData(
        plan: RestoreImportPlan,
        routePoints: [RoutePointDraft],
        conflictPolicy: RestoreConflictPolicy = .skipExisting,
        explicitlyConfirmed: Bool = false
    ) throws -> RestoreImportResult {
        guard explicitlyConfirmed else {
            throw RestoreImportRepositoryError.explicitConfirmationRequired
        }

        guard conflictPolicy != .replaceOnlyIfSameRecordingIdAndExplicitlyConfirmed else {
            throw RestoreImportRepositoryError.destructivePolicyNotAllowed
        }

        throw RestoreImportRepositoryError.importNotImplemented
    }
}
