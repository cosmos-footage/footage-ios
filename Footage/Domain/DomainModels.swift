//
//  DomainModels.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import Foundation

struct GeoCoordinate: Codable, Equatable, Hashable, CustomDebugStringConvertible {
    var latitude: Double
    var longitude: Double

    var isValid: Bool {
        (-90...90).contains(latitude) && (-180...180).contains(longitude)
    }

    var debugDescription: String {
        "GeoCoordinate(redacted)"
    }
}

struct RoutePointEntity: Codable, Equatable, CustomDebugStringConvertible {
    var pointId: PointID
    var recordingId: RecordingID
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var timestamp: Date
    var coordinate: GeoCoordinate
    var horizontalAccuracy: Double?
    var altitude: Double?
    var speed: Double?
    var course: Double?
    var colorCategoryId: String
    var setAsStart: Bool
    var sequence: Int
    var syncStatus: SyncStatus
    var mediaReferences: [MediaReference]
    var notes: [FootageNote]

    var debugDescription: String {
        "RoutePointEntity(pointId: \(pointId.rawValue), recordingId: \(recordingId.rawValue), coordinate: redacted, mediaCount: \(mediaReferences.count), noteCount: \(notes.count), syncStatus: \(syncStatus.rawValue))"
    }
}

struct RecordingSessionEntity: Codable, Equatable {
    var recordingId: RecordingID
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var installationId: InstallationID
    var localDate: String
    var startedAt: Date
    var endedAt: Date?
    var distanceMeters: Double
    var pointCount: Int
    var primaryColorCategoryId: String?
    var state: RecordingLifecycleState
    var syncStatus: SyncStatus
}

struct DaySummaryEntity: Codable, Equatable {
    var localDate: String
    var ownerId: OwnerID?
    var deviceId: DeviceID?
    var distanceMeters: Double
    var recordingCount: Int
    var pointCount: Int
    var previewAssetId: String?
    var syncStatus: SyncStatus
}

struct JourneyEntity: Codable, Equatable {
    var recordingId: RecordingID
    var localDate: String
    var startedAt: Date
    var endedAt: Date?
    var distanceMeters: Double
    var pointCount: Int
    var primaryColorCategoryId: String?
    var mediaCount: Int
    var noteCount: Int
    var syncStatus: SyncStatus
}

struct FootageColorCategory: Codable, Equatable, Hashable {
    var id: String
    var displayName: String
    var hexRGBA: String
    var sortOrder: Int
}

struct BadgeProgress: Codable, Equatable, Hashable {
    var badgeId: String
    var title: String
    var currentValue: Double
    var requiredValue: Double
    var isUnlocked: Bool
}

struct PlaceSummaryEntity: Codable, Equatable, Hashable {
    var locality: String
    var visitCount: Int
    var distanceMeters: Double
    var lastVisitedAt: Date?
}

struct MediaReference: Codable, Equatable, Hashable, CustomDebugStringConvertible {
    enum Kind: String, Codable {
        case photo
        case preview
        case realmExport
    }

    var assetId: String
    var kind: Kind
    var localIdentifier: String?
    var objectId: String?
    var contentType: String
    var byteSize: Int?
    var checksumSha256: String?

    var debugDescription: String {
        "MediaReference(assetId: \(assetId), kind: \(kind.rawValue), localIdentifier: redacted, objectId: redacted)"
    }
}

struct FootageNote: Codable, Equatable, Hashable, CustomDebugStringConvertible {
    var noteId: String
    var text: String
    var createdAt: Date
    var updatedAt: Date?

    var debugDescription: String {
        "FootageNote(noteId: \(noteId), text: redacted)"
    }
}

enum RecordingLifecycleState: String, Codable, Equatable {
    case idle
    case recording
    case paused
    case stopped

    var isAcceptingPoints: Bool {
        self == .recording
    }
}

struct WidgetStateSnapshot: Codable, Equatable {
    var isTracking: Bool
    var distanceTodayMeters: Double
    var distanceTotalMeters: Double
    var selectedColorCategoryId: String
    var updatedAt: Date
}

struct UserProfilePreferences: Codable, Equatable {
    var displayName: String
    var profileImageAssetId: String?
    var preferredColorCategoryId: String?
    var notificationsEnabled: Bool
    var lockEnabled: Bool
}
