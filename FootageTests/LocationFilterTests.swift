//
//  LocationFilterTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import XCTest
@testable import footage

final class LocationFilterTests: XCTestCase {
    func testAcceptsFirstValidLocation() {
        let filter = LocationFilter()
        let current = location(latitude: 37.0, longitude: 127.0, speed: 0)

        let decision = filter.decision(
            for: current,
            previous: nil,
            noSpeedCounter: 0,
            alwaysOnCount: 0,
            isAlwaysOn: false
        )

        XCTAssertEqual(decision, .accepted)
    }

    func testRejectsSpeedLimitExceeded() {
        let filter = LocationFilter()
        let previous = location(latitude: 37.0, longitude: 127.0, speed: 0, timestamp: Date(timeIntervalSince1970: 100))
        let current = location(latitude: 37.0, longitude: 127.01, speed: 20, timestamp: Date(timeIntervalSince1970: 101))

        let decision = filter.decision(
            for: current,
            previous: previous,
            noSpeedCounter: 0,
            alwaysOnCount: 0,
            isAlwaysOn: false
        )

        XCTAssertEqual(decision, .rejected(.speedLimitExceeded))
    }

    func testRejectsAlwaysOnIndoorLikelyAfterNoSpeedLimit() {
        let filter = LocationFilter()
        let previous = location(latitude: 37.0, longitude: 127.0, speed: 0, timestamp: Date(timeIntervalSince1970: 100))
        let current = location(latitude: 37.0, longitude: 127.0, speed: 0, timestamp: Date(timeIntervalSince1970: 101))

        let decision = filter.decision(
            for: current,
            previous: previous,
            noSpeedCounter: 5,
            alwaysOnCount: 5,
            isAlwaysOn: true
        )

        XCTAssertEqual(decision, .rejected(.alwaysOnIndoorLikely))
    }

    private func location(
        latitude: Double,
        longitude: Double,
        speed: CLLocationSpeed,
        timestamp: Date = Date()
    ) -> CLLocation {
        CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            course: 0,
            speed: speed,
            timestamp: timestamp
        )
    }
}
