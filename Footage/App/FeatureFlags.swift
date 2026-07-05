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

enum AppRootDestination: Equatable {
    case legacyFirstLaunch
    case legacyMainTabs
    case renewedSwiftUIShell
}

struct AppRootRoute: Equatable {
    var destination: AppRootDestination
    var storyboardName: String?
    var storyboardIdentifier: String?

    var usesStoryboard: Bool {
        storyboardName != nil && storyboardIdentifier != nil
    }

    static let legacyFirstLaunch = AppRootRoute(
        destination: .legacyFirstLaunch,
        storyboardName: "FirstLaunch",
        storyboardIdentifier: "FL_VideoVC"
    )

    static let legacyMainTabs = AppRootRoute(
        destination: .legacyMainTabs,
        storyboardName: "Main",
        storyboardIdentifier: "TabBarController"
    )

    static let renewedSwiftUIShell = AppRootRoute(
        destination: .renewedSwiftUIShell,
        storyboardName: nil,
        storyboardIdentifier: nil
    )
}

struct AppRootRouter: Equatable {
    var featureFlags: FeatureFlags

    init(featureFlags: FeatureFlags = .disabled) {
        self.featureFlags = featureFlags
    }

    func route(userState: String?) -> AppRootRoute {
        guard userState != nil else {
            return .legacyFirstLaunch
        }

        if featureFlags.isNewUIRunwayEnabled {
            return .renewedSwiftUIShell
        }

        return .legacyMainTabs
    }
}
