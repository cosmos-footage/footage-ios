//
//  RestoreDuplicateDetectorTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import XCTest
@testable import footage

final class RestoreDuplicateDetectorTests: XCTestCase {
    func testDuplicateCandidateCountUsesRecordingAndPointIds() {
        let detector = RestoreDuplicateDetector()
        let duplicate = makePoint(pointId: "pt_existing")
        let newPoint = makePoint(pointId: "pt_new")

        let count = detector.duplicateCandidateCount(
            incomingPoints: [duplicate, newPoint],
            existingPointKeys: [detector.key(for: duplicate)]
        )

        XCTAssertEqual(count, 1)
    }

    func testFallbackKeyRoundsCoordinatesToFiveDecimalPlaces() {
        let detector = RestoreDuplicateDetector()
        let point = makePoint(
            timestamp: Date(timeIntervalSince1970: 100),
            latitude: 37.1234567,
            longitude: 127.7654321
        )

        XCTAssertEqual(detector.fallbackKey(for: point), "100.0:37.12346:127.76543")
    }

    private func makePoint(
        pointId: String = "pt_1",
        timestamp: Date = Date(timeIntervalSince1970: 100),
        latitude: Double = 37,
        longitude: Double = 127
    ) -> RoutePointDraft {
        RoutePointDraft(
            pointId: PointID(rawValue: pointId),
            recordingId: RecordingID(rawValue: "rec_1"),
            ownerId: OwnerID(rawValue: "own_1"),
            deviceId: DeviceID(rawValue: "dev_1"),
            timestamp: timestamp,
            latitude: latitude,
            longitude: longitude,
            horizontalAccuracy: 5,
            altitude: nil,
            speed: nil,
            course: nil,
            color: "#EADE4Cff",
            setAsStart: false,
            sequence: 0,
            syncStatus: .pending
        )
    }
}
