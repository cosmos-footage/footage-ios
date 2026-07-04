//
//  RoutePointNDJSONSerializer.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct RoutePointNDJSONRecord: Codable, Equatable {
    var pointId: String
    var recordingId: String
    var timestamp: Date
    var latitude: Double
    var longitude: Double
    var color: String
    var setAsStart: Bool
    var sequence: Int
    var photoCount: Int
    var noteCount: Int
}

struct RoutePointNDJSONSerializer {
    private let encoder: JSONEncoder

    init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder
    }

    func records(
        from day: DayExportDraft,
        installationId: InstallationID,
        recordingId: RecordingID
    ) -> [RoutePointNDJSONRecord] {
        day.points.enumerated().map { index, point in
            RoutePointNDJSONRecord(
                pointId: deterministicPointId(
                    installationId: installationId,
                    localDate: day.date,
                    timestamp: point.timestamp,
                    sequence: index
                ).rawValue,
                recordingId: recordingId.rawValue,
                timestamp: point.timestamp,
                latitude: point.latitude,
                longitude: point.longitude,
                color: point.color,
                setAsStart: point.setAsStart,
                sequence: index,
                photoCount: point.photoCount,
                noteCount: point.noteCount
            )
        }
    }

    func ndjson(from records: [RoutePointNDJSONRecord]) throws -> String {
        try records.map { record in
            let data = try encoder.encode(record)
            return String(data: data, encoding: .utf8) ?? ""
        }.joined(separator: "\n")
    }

    func deterministicRecordingId(installationId: InstallationID, localDate: Int) -> RecordingID {
        RecordingID(rawValue: "rec_\(installationId.rawValue)_day_\(localDate)")
    }

    private func deterministicPointId(
        installationId: InstallationID,
        localDate: Int,
        timestamp: Date,
        sequence: Int
    ) -> PointID {
        let timestampValue = Int(timestamp.timeIntervalSince1970)
        return PointID(rawValue: "pt_\(installationId.rawValue)_\(localDate)_\(sequence)_\(timestampValue)")
    }
}
