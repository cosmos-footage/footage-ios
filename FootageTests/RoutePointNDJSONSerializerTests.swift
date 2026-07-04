//
//  RoutePointNDJSONSerializerTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import XCTest
@testable import footage

final class RoutePointNDJSONSerializerTests: XCTestCase {
    func testRecordsUseDeterministicIdsAndSequences() {
        let serializer = RoutePointNDJSONSerializer()
        let installationId = InstallationID(rawValue: "install_test")
        let recordingId = serializer.deterministicRecordingId(installationId: installationId, localDate: 20260704)
        let timestamp = Date(timeIntervalSince1970: 100)
        let day = DayExportDraft(
            date: 20260704,
            distanceMeters: 10,
            points: [
                RoutePointExportDraft(
                    timestamp: timestamp,
                    latitude: 37.0,
                    longitude: 127.0,
                    color: "#EADE4Cff",
                    setAsStart: true,
                    photoCount: 1,
                    noteCount: 1
                )
            ]
        )

        let records = serializer.records(from: day, installationId: installationId, recordingId: recordingId)

        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].recordingId, "rec_install_test_day_20260704")
        XCTAssertEqual(records[0].pointId, "pt_install_test_20260704_0_100")
        XCTAssertEqual(records[0].sequence, 0)
        XCTAssertEqual(records[0].photoCount, 1)
        XCTAssertEqual(records[0].noteCount, 1)
    }

    func testNDJSONProducesOneJSONRecordPerLine() throws {
        let serializer = RoutePointNDJSONSerializer()
        let records = [
            RoutePointNDJSONRecord(
                pointId: "pt_1",
                recordingId: "rec_1",
                timestamp: Date(timeIntervalSince1970: 100),
                latitude: 37.0,
                longitude: 127.0,
                color: "#EADE4Cff",
                setAsStart: true,
                sequence: 0,
                photoCount: 0,
                noteCount: 0
            ),
            RoutePointNDJSONRecord(
                pointId: "pt_2",
                recordingId: "rec_1",
                timestamp: Date(timeIntervalSince1970: 101),
                latitude: 37.1,
                longitude: 127.1,
                color: "#EADE4Cff",
                setAsStart: false,
                sequence: 1,
                photoCount: 0,
                noteCount: 0
            )
        ]

        let ndjson = try serializer.ndjson(from: records)
        let lines = ndjson.split(separator: "\n")

        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[0].contains(#""pointId":"pt_1""#))
        XCTAssertTrue(lines[1].contains(#""pointId":"pt_2""#))
    }
}
