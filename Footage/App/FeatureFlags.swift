//
//  FeatureFlags.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct FeatureFlags: Equatable {
    var isCloudBackupEnabled: Bool
    var isRestoreEnabled: Bool
    var isAuthEnabled: Bool
    var isDevelopmentUploadEnabled: Bool
    var isNewUIRunwayEnabled: Bool

    init(
        isCloudBackupEnabled: Bool = false,
        isRestoreEnabled: Bool = false,
        isAuthEnabled: Bool = false,
        isDevelopmentUploadEnabled: Bool = false,
        isNewUIRunwayEnabled: Bool = false
    ) {
        self.isCloudBackupEnabled = isCloudBackupEnabled
        self.isRestoreEnabled = isRestoreEnabled
        self.isAuthEnabled = isAuthEnabled
        self.isDevelopmentUploadEnabled = isDevelopmentUploadEnabled
        self.isNewUIRunwayEnabled = isNewUIRunwayEnabled
    }

    static let disabled = FeatureFlags()
}
