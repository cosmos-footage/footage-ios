//
//  DistanceCalculator.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import Foundation

struct DistanceCalculator {
    func distanceMeters(from previous: CLLocation?, to current: CLLocation) -> CLLocationDistance {
        guard let previous = previous else { return 0 }
        return current.distance(from: previous)
    }

    func elapsedSeconds(from previous: CLLocation?, to current: CLLocation) -> TimeInterval? {
        guard let previous = previous else { return nil }

        let elapsed = current.timestamp.timeIntervalSince(previous.timestamp)
        return elapsed > 0 ? elapsed : nil
    }

    func speedMetersPerSecond(from previous: CLLocation?, to current: CLLocation) -> CLLocationSpeed? {
        guard let elapsed = elapsedSeconds(from: previous, to: current), elapsed > 0 else {
            return nil
        }

        return distanceMeters(from: previous, to: current) / elapsed
    }
}
