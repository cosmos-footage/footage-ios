//
//  Identifiers.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct OwnerID: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

struct DeviceID: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

struct InstallationID: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

struct RecordingID: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

struct PointID: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

struct SyncBatchID: RawRepresentable, Codable, Hashable {
    let rawValue: String
}

extension InstallationID {
    static func generate() -> InstallationID {
        InstallationID(rawValue: "inst_" + UUID().uuidString.lowercased())
    }
}

extension RecordingID {
    static func generate() -> RecordingID {
        RecordingID(rawValue: "rec_" + UUID().uuidString.lowercased())
    }
}

extension PointID {
    static func generate() -> PointID {
        PointID(rawValue: "pt_" + UUID().uuidString.lowercased())
    }
}

extension SyncBatchID {
    static func generate() -> SyncBatchID {
        SyncBatchID(rawValue: "batch_" + UUID().uuidString.lowercased())
    }
}
