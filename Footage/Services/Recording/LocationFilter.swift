//
//  LocationFilter.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import Foundation

struct LocationFilter {
    struct Configuration {
        var speedLimitMetersPerSecond: CLLocationSpeed = 8
        var refreshRateSeconds: TimeInterval = 2.5
        var walkingSpeedThresholdMetersPerSecond: CLLocationSpeed = 0.1
        var alwaysOnWarmupCount: Int = 4
        var alwaysOnNoSpeedLimitCount: Int = 4

        var distanceLimitMeters: CLLocationDistance {
            speedLimitMetersPerSecond * refreshRateSeconds
        }
    }

    enum RejectionReason: Equatable {
        case invalidCoordinate
        case speedLimitExceeded
        case distanceLimitExceeded
        case alwaysOnIndoorLikely
        case notMoving
        case alwaysOnWarmup
    }

    enum Decision: Equatable {
        case accepted
        case rejected(RejectionReason)
    }

    private let configuration: Configuration
    private let distanceCalculator: DistanceCalculator

    init(
        configuration: Configuration = Configuration(),
        distanceCalculator: DistanceCalculator = DistanceCalculator()
    ) {
        self.configuration = configuration
        self.distanceCalculator = distanceCalculator
    }

    func decision(
        for current: CLLocation,
        previous: CLLocation?,
        noSpeedCounter: Int,
        alwaysOnCount: Int,
        isAlwaysOn: Bool
    ) -> Decision {
        guard CLLocationCoordinate2DIsValid(current.coordinate) else {
            return .rejected(.invalidCoordinate)
        }

        let distance = distanceCalculator.distanceMeters(from: previous, to: current)
        let calculatedSpeed = distanceCalculator.speedMetersPerSecond(from: previous, to: current)
        let speed = calculatedSpeed ?? current.speed

        if speed > configuration.speedLimitMetersPerSecond {
            return .rejected(.speedLimitExceeded)
        }

        if distance > configuration.distanceLimitMeters {
            return .rejected(.distanceLimitExceeded)
        }

        if isAlwaysOn && noSpeedCounter > configuration.alwaysOnNoSpeedLimitCount {
            return .rejected(.alwaysOnIndoorLikely)
        }

        guard let previous = previous else {
            return .accepted
        }

        if current.speed < configuration.walkingSpeedThresholdMetersPerSecond &&
            previous.speed < configuration.walkingSpeedThresholdMetersPerSecond {
            return .rejected(.notMoving)
        }

        if isAlwaysOn && alwaysOnCount < configuration.alwaysOnWarmupCount {
            return .rejected(.alwaysOnWarmup)
        }

        return .accepted
    }
}
