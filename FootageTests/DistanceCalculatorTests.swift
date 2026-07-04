//
//  DistanceCalculatorTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import XCTest
@testable import footage

final class DistanceCalculatorTests: XCTestCase {
    func testDistanceMetersReturnsZeroWithoutPreviousLocation() {
        let calculator = DistanceCalculator()
        let current = CLLocation(latitude: 37.0, longitude: 127.0)

        XCTAssertEqual(calculator.distanceMeters(from: nil, to: current), 0)
    }

    func testSpeedMetersPerSecondUsesElapsedTime() throws {
        let calculator = DistanceCalculator()
        let previous = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: 127.0),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            timestamp: Date(timeIntervalSince1970: 100)
        )
        let current = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: 127.001),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            timestamp: Date(timeIntervalSince1970: 110)
        )

        let expectedSpeed = current.distance(from: previous) / 10
        let speed = try XCTUnwrap(calculator.speedMetersPerSecond(from: previous, to: current))
        XCTAssertEqual(speed, expectedSpeed, accuracy: 0.0001)
    }

    func testSpeedMetersPerSecondRejectsNonPositiveElapsedTime() {
        let calculator = DistanceCalculator()
        let timestamp = Date(timeIntervalSince1970: 100)
        let previous = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: 127.0),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            timestamp: timestamp
        )
        let current = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 37.0, longitude: 127.001),
            altitude: 0,
            horizontalAccuracy: 5,
            verticalAccuracy: 5,
            timestamp: timestamp
        )

        XCTAssertNil(calculator.speedMetersPerSecond(from: previous, to: current))
    }
}
