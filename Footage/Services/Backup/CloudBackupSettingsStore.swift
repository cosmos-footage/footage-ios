//
//  CloudBackupSettingsStore.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct CloudBackupSettingsStore {
    private enum Key {
        static let isOptedIn = "Footage.CloudBackup.isOptedIn"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isOptedIn: Bool {
        get { defaults.bool(forKey: Key.isOptedIn) }
        set { defaults.set(newValue, forKey: Key.isOptedIn) }
    }
}
