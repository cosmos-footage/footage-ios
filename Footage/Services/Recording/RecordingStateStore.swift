//
//  RecordingStateStore.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum AppGroupWidgetStateKeys {
    static let suiteName = "group.footage"
    static let isTracking = "isTracking"
    static let distanceToday = "distanceToday"
    static let distanceTotal = "distanceTotal"
    static let selectedColor = "selectedColor"
}

final class RecordingStateStore: WidgetStateStore {
    private let defaults: UserDefaults
    let usesAppGroupStore: Bool

    init(suiteName: String = AppGroupWidgetStateKeys.suiteName, fallbackDefaults: UserDefaults = .standard) {
        if let appGroupDefaults = UserDefaults(suiteName: suiteName) {
            defaults = appGroupDefaults
            usesAppGroupStore = true
        } else {
            defaults = fallbackDefaults
            usesAppGroupStore = false
        }
    }

    var isTracking: Bool {
        get { defaults.bool(forKey: AppGroupWidgetStateKeys.isTracking) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.isTracking) }
    }

    var distanceToday: Double {
        get { defaults.double(forKey: AppGroupWidgetStateKeys.distanceToday) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.distanceToday) }
    }

    var distanceTotal: Double {
        get { defaults.double(forKey: AppGroupWidgetStateKeys.distanceTotal) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.distanceTotal) }
    }

    var selectedColor: String? {
        get { defaults.string(forKey: AppGroupWidgetStateKeys.selectedColor) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.selectedColor) }
    }
}
