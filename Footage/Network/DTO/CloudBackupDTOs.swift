//
//  CloudBackupDTOs.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct BootstrapRequest: Codable, Equatable {
    struct Device: Codable, Equatable {
        var vendorIdHash: String?
        var model: String
        var osVersion: String
    }

    struct Capabilities: Codable, Equatable {
        var schemaVersion: Int
        var supportsGzip: Bool
        var supportsRestore: Bool
    }

    var installationId: String
    var appBundleId: String
    var appVersion: String
    var platform: String
    var device: Device
    var capabilities: Capabilities
}

struct BootstrapResponse: Codable, Equatable {
    struct Upload: Codable, Equatable {
        var maxBatchBytes: Int
        var acceptedContentTypes: [String]
    }

    var ownerId: String
    var deviceId: String
    var installationId: String
    var anonymousDeviceToken: String
    var tokenExpiresAt: Date?
    var serverTime: Date
    var minimumClientSchemaVersion: Int
    var upload: Upload
}

struct PresignUploadRequest: Codable, Equatable {
    var ownerId: String
    var deviceId: String
    var recordingId: String
    var syncBatchId: String
    var objectType: String
    var contentType: String
    var contentLength: Int
    var checksumSha256: String?
}

struct PresignUploadResponse: Codable, Equatable {
    var uploadId: String
    var method: String
    var url: URL
    var expiresAt: Date
    var requiredHeaders: [String: String]
    var objectKey: String
}

struct UploadCompleteRequest: Codable, Equatable {
    var uploadId: String
    var ownerId: String
    var deviceId: String
    var recordingId: String
    var syncBatchId: String
    var objectKey: String
    var checksumSha256: String?
    var contentLength: Int
}

struct UploadCompleteResponse: Codable, Equatable {
    var uploadId: String
    var status: String
    var recordedAt: Date
}

struct SyncBatchRequest: Codable, Equatable {
    struct Recording: Codable, Equatable {
        struct UploadedObject: Codable, Equatable {
            var objectType: String
            var objectKey: String
            var checksumSha256: String?
            var contentLength: Int
        }

        var recordingId: String
        var localDate: String
        var pointCount: Int
        var distanceMeters: Double?
        var objects: [UploadedObject]
    }

    var ownerId: String
    var deviceId: String
    var installationId: String
    var syncBatchId: String
    var schemaVersion: Int
    var startedAt: Date
    var completedAt: Date
    var recordings: [Recording]
}

struct SyncBatchResponse: Codable, Equatable {
    var syncBatchId: String
    var status: String
    var acceptedRecordings: Int
    var acceptedObjects: Int
    var serverTime: Date
}

struct RestoreManifestResponse: Codable, Equatable {
    struct Recording: Codable, Equatable {
        struct DownloadObject: Codable, Equatable {
            var objectType: String
            var downloadUrl: URL
            var expiresAt: Date
            var checksumSha256: String?
            var contentLength: Int
        }

        var recordingId: String
        var deviceId: String
        var localDate: String
        var pointCount: Int
        var distanceMeters: Double
        var objects: [DownloadObject]
    }

    var ownerId: String
    var generatedAt: Date
    var schemaVersion: Int
    var recordings: [Recording]
}

struct AuthLinkRequest: Codable, Equatable {
    var ownerId: String
    var provider: String
    var providerToken: String
    var authorizationCode: String?
    var nonce: String?
}

struct AuthLinkResponse: Codable, Equatable {
    var ownerId: String
    var authUserId: String
    var provider: String
    var linkedAt: Date
}

struct DeleteCloudDataRequest: Codable, Equatable {
    var ownerId: String
    var confirmation: String
    var reason: String?
}

struct DeleteCloudDataResponse: Codable, Equatable {
    var ownerId: String
    var status: String
    var requestedAt: Date
    var estimatedCompletionAt: Date?
}
