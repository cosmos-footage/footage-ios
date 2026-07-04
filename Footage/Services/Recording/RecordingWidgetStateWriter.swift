//
//  RecordingWidgetStateWriter.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import Foundation

protocol RecordingWidgetStateWriting: AnyObject {
    var isTracking: Bool { get set }
    var distanceToday: Double { get set }
    var distanceTotal: Double { get set }
    var selectedColor: String? { get set }

    func addDistance(_ distance: CLLocationDistance)
}

extension RecordingWidgetStateWriting {
    func addDistance(_ distance: CLLocationDistance) {
        distanceToday += distance
        distanceTotal += distance
    }
}

extension RecordingStateStore: RecordingWidgetStateWriting {}
