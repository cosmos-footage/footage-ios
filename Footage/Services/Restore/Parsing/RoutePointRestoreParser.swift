//
//  RoutePointRestoreParser.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum RoutePointRestoreParserError: Error {
    case invalidUTF8
    case gzipNotSupportedYet
}

struct RoutePointRestoreParser {
    private let decoder: JSONDecoder

    init() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func parse(data: Data, isGzipped: Bool = false) throws -> [RoutePointDraft] {
        guard !isGzipped else {
            throw RoutePointRestoreParserError.gzipNotSupportedYet
        }

        guard let ndjson = String(data: data, encoding: .utf8) else {
            throw RoutePointRestoreParserError.invalidUTF8
        }

        return try parse(ndjson: ndjson)
    }

    func parse(ndjson: String) throws -> [RoutePointDraft] {
        try ndjson
            .split(whereSeparator: \.isNewline)
            .enumerated()
            .map { sequence, line in
                let data = Data(line.utf8)
                let record = try decoder.decode(RoutePointNDJSONRecord.self, from: data)
                return RoutePointDraft(
                    pointId: PointID(rawValue: record.pointId),
                    recordingId: RecordingID(rawValue: record.recordingId),
                    ownerId: nil,
                    deviceId: nil,
                    timestamp: record.timestamp,
                    latitude: record.latitude,
                    longitude: record.longitude,
                    horizontalAccuracy: nil,
                    altitude: nil,
                    speed: nil,
                    course: nil,
                    color: record.color,
                    setAsStart: record.setAsStart,
                    sequence: record.sequence == sequence ? record.sequence : sequence,
                    syncStatus: .localOnly
                )
            }
    }
}
