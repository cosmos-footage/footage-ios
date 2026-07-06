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
    var areRenewedSettingsDetailRoutesEnabled: Bool

    init(
        isCloudBackupEnabled: Bool = false,
        isRestoreEnabled: Bool = false,
        isAuthEnabled: Bool = false,
        isDevelopmentUploadEnabled: Bool = false,
        isNewUIRunwayEnabled: Bool = false,
        areRenewedSettingsDetailRoutesEnabled: Bool = false
    ) {
        self.isCloudBackupEnabled = isCloudBackupEnabled
        self.isRestoreEnabled = isRestoreEnabled
        self.isAuthEnabled = isAuthEnabled
        self.isDevelopmentUploadEnabled = isDevelopmentUploadEnabled
        self.isNewUIRunwayEnabled = isNewUIRunwayEnabled
        self.areRenewedSettingsDetailRoutesEnabled = areRenewedSettingsDetailRoutesEnabled
    }

    static let disabled = FeatureFlags()

    static func r15QAOverride(
        arguments: [String],
        environment: [String: String]
    ) -> FeatureFlags {
        var flags = FeatureFlags.disabled
        flags.isNewUIRunwayEnabled = arguments.contains("--footage-enable-renewed-ui")
            || environment["FOOTAGE_ENABLE_RENEWED_UI"] == "1"
        flags.areRenewedSettingsDetailRoutesEnabled = arguments.contains("--footage-enable-renewed-settings-details")
            || environment["FOOTAGE_ENABLE_RENEWED_SETTINGS_DETAILS"] == "1"
        return flags
    }
}
