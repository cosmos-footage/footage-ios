//
//  MigrationExportModels.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct RoutePointExportDraft: Codable, Equatable {
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var color: String
    var setAsStart: Bool
    var photoCount: Int
    var noteCount: Int
}

struct DayExportDraft: Codable, Equatable {
    var date: Int
    var distanceMeters: Double
    var points: [RoutePointExportDraft]
}

struct MigrationExportDraft: Codable, Equatable {
    var exportedAt: Date
    var installationId: InstallationID
    var days: [DayExportDraft]
}
