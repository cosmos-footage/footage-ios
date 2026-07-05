//
//  DomainPoliciesTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/05.
//

import XCTest
@testable import footage

final class DomainPoliciesTests: XCTestCase {
    func testRoutePointValidationRejectsInvalidCoordinate() {
        let policy = RoutePointValidationPolicy()
        let point = makePoint(
            coordinate: GeoCoordinate(latitude: 100, longitude: 127),
            timestamp: Date(timeIntervalSince1970: 100)
        )

        XCTAssertEqual(
            policy.rejectionReason(for: point, recordingStartedAt: Date(timeIntervalSince1970: 90)),
            .invalidCoordinate
        )
    }

    func testRoutePointValidationRejectsFutureRecordingStartMismatch() {
        let policy = RoutePointValidationPolicy()
        let point = makePoint(timestamp: Date(timeIntervalSince1970: 100))

        XCTAssertEqual(
            policy.rejectionReason(for: point, recordingStartedAt: Date(timeIntervalSince1970: 101)),
            .timestampBeforeRecordingStart
        )
    }

    func testRecordingStateTransitionsPreserveLocalFirstPointIngestionBoundary() {
        let policy = RecordingStateTransitionPolicy()

        XCTAssertEqual(try? policy.transition(from: .idle, event: .start).get(), .recording)
        XCTAssertEqual(try? policy.transition(from: .recording, event: .ingestPoint).get(), .recording)
        XCTAssertEqual(try? policy.transition(from: .recording, event: .pause).get(), .paused)
        XCTAssertEqual(policy.transition(from: .paused, event: .ingestPoint), .failure(.cannotIngestPoint))
        XCTAssertEqual(try? policy.transition(from: .paused, event: .stop).get(), .stopped)
    }

    func testBadgeEligibilitySortsUnlockedMilestonesAndClampsProgress() {
        let policy = BadgeEligibilityPolicy()

        XCTAssertEqual(policy.unlockedMilestones(currentValue: 50, milestones: [100, 10, 50, -1]), [10, 50])
        XCTAssertEqual(policy.progress(currentValue: 25, requiredValue: 100), 0.25)
        XCTAssertEqual(policy.progress(currentValue: 150, requiredValue: 100), 1)
        XCTAssertEqual(policy.progress(currentValue: -5, requiredValue: 100), 0)
    }

    func testDateGroupingUsesDeterministicCalendarKeys() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let policy = DateGroupingPolicy(calendar: calendar)
        let date = Date(timeIntervalSince1970: 1_772_582_400)

        XCTAssertEqual(policy.dayKey(for: date), "2026-03-04")
        XCTAssertEqual(policy.monthKey(for: date), "2026-03")
    }

    func testColorCategorySelectionUsesRequestedCategoryOrStableFallback() {
        let policy = ColorCategorySelectionPolicy()
        let categories = [
            FootageColorCategory(id: "blue", displayName: "Blue", hexRGBA: "#206491ff", sortOrder: 2),
            FootageColorCategory(id: "yellow", displayName: "Yellow", hexRGBA: "#EADE4Cff", sortOrder: 1)
        ]

        XCTAssertEqual(policy.selectedCategory(requestedId: "blue", categories: categories)?.id, "blue")
        XCTAssertEqual(policy.selectedCategory(requestedId: "missing", categories: categories)?.id, "yellow")
        XCTAssertTrue(policy.isValidHexRGBA("#EADE4Cff"))
        XCTAssertFalse(policy.isValidHexRGBA("EADE4Cff"))
    }

    private func makePoint(
        coordinate: GeoCoordinate = GeoCoordinate(latitude: 37, longitude: 127),
        timestamp: Date,
        sequence: Int = 0
    ) -> RoutePointEntity {
        RoutePointEntity(
            pointId: PointID(rawValue: "pt_test"),
            recordingId: RecordingID(rawValue: "rec_test"),
            ownerId: nil,
            deviceId: nil,
            timestamp: timestamp,
            coordinate: coordinate,
            horizontalAccuracy: 5,
            altitude: nil,
            speed: nil,
            course: nil,
            colorCategoryId: "#EADE4Cff",
            setAsStart: false,
            sequence: sequence,
            syncStatus: .localOnly,
            mediaReferences: [],
            notes: []
        )
    }
}
