//
//  BackupPayloadStager.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum BackupPayloadCompression: Equatable {
    case none
    case gzip
}

struct StagedBackupPayloadMetadata: Equatable {
    let localFileURL: URL
    let contentType: String
    let contentLength: Int
    let checksumSha256: String?
    let compression: BackupPayloadCompression
}

protocol BackupPayloadStager {
    func stagePayload(
        _ data: Data,
        contentType: String,
        checksumSha256: String?,
        compression: BackupPayloadCompression
    ) throws -> StagedBackupPayloadMetadata

    func removeStagedPayload(at localFileURL: URL) throws
}
