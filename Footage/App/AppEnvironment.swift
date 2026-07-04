//
//  AppEnvironment.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct AppEnvironment: Equatable {
    var featureFlags: FeatureFlags
    var cloudBackupBaseURL: URL
    var cloudBackupRequestTimeout: TimeInterval
    var cloudBackupSchemaVersion: Int

    init(
        featureFlags: FeatureFlags = .disabled,
        cloudBackupBaseURL: URL = URL(string: "https://footage-cloud-backup.invalid")!,
        cloudBackupRequestTimeout: TimeInterval = 30,
        cloudBackupSchemaVersion: Int = 1
    ) {
        self.featureFlags = featureFlags
        self.cloudBackupBaseURL = cloudBackupBaseURL
        self.cloudBackupRequestTimeout = cloudBackupRequestTimeout
        self.cloudBackupSchemaVersion = cloudBackupSchemaVersion
    }

    static let current = AppEnvironment()
}
