//
//  LocalPreferencesRepositories.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import Foundation

struct UserDefaultsUserProfileRepository: UserProfileRepository {
    private enum Key {
        static let displayName = "userName"
        static let profileImageData = "profileImage"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadProfile() -> UserProfileSnapshot {
        UserProfileSnapshot(
            displayName: defaults.string(forKey: Key.displayName),
            profileImageData: defaults.data(forKey: Key.profileImageData)
        )
    }

    func saveDisplayName(_ displayName: String?) {
        defaults.set(displayName, forKey: Key.displayName)
    }

    func saveProfileImageData(_ data: Data?) {
        defaults.set(data, forKey: Key.profileImageData)
    }
}
