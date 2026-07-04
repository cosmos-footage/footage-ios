//
//  RecordingStateStore.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

final class RecordingStateStore: WidgetStateStore {
    private enum Key {
        static let isTracking = "isTracking"
        static let distanceToday = "distanceToday"
        static let distanceTotal = "distanceTotal"
        static let selectedColor = "selectedColor"
    }

    private let defaults: UserDefaults
    let usesAppGroupStore: Bool

    init(suiteName: String = "group.footage", fallbackDefaults: UserDefaults = .standard) {
        if let appGroupDefaults = UserDefaults(suiteName: suiteName) {
            defaults = appGroupDefaults
            usesAppGroupStore = true
        } else {
            defaults = fallbackDefaults
            usesAppGroupStore = false
        }
    }

    var isTracking: Bool {
        get { defaults.bool(forKey: Key.isTracking) }
        set { defaults.set(newValue, forKey: Key.isTracking) }
    }

    var distanceToday: Double {
        get { defaults.double(forKey: Key.distanceToday) }
        set { defaults.set(newValue, forKey: Key.distanceToday) }
    }

    var distanceTotal: Double {
        get { defaults.double(forKey: Key.distanceTotal) }
        set { defaults.set(newValue, forKey: Key.distanceTotal) }
    }

    var selectedColor: String? {
        get { defaults.string(forKey: Key.selectedColor) }
        set { defaults.set(newValue, forKey: Key.selectedColor) }
    }
}
