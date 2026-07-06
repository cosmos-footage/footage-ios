//
//  AppRootRouting.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import Foundation

enum AppRootDestination: Equatable {
    case legacyFirstLaunch
    case legacyMainTabs
    case renewedUIKitShell
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

    static let renewedUIKitShell = AppRootRoute(
        destination: .renewedUIKitShell,
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
            return .renewedUIKitShell
        }

        return .legacyMainTabs
    }
}
