//
//  RenewedShellStoryboardFactory.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import UIKit

struct StoryboardSceneDescriptor: Equatable, Hashable {
    var storyboardName: String
    var viewControllerIdentifier: String

    static let legacyMainTabs = StoryboardSceneDescriptor(
        storyboardName: "Main",
        viewControllerIdentifier: "TabBarController"
    )

    static let legacyFirstLaunch = StoryboardSceneDescriptor(
        storyboardName: "FirstLaunch",
        viewControllerIdentifier: "FL_VideoVC"
    )

    static let legacyPasswordUnlock = StoryboardSceneDescriptor(
        storyboardName: "Main",
        viewControllerIdentifier: "PasswordVC"
    )
}

protocol RenewedShellStoryboardSceneProviding {
    func sceneDescriptor(for tab: RenewedShellTab) -> StoryboardSceneDescriptor?
}

struct LegacyRenewedShellStoryboardSceneProvider: RenewedShellStoryboardSceneProviding {
    func sceneDescriptor(for tab: RenewedShellTab) -> StoryboardSceneDescriptor? {
        switch tab.kind {
        case .today:
            return StoryboardSceneDescriptor(
                storyboardName: "Home",
                viewControllerIdentifier: "HomeViewController"
            )
        case .timeline:
            return StoryboardSceneDescriptor(
                storyboardName: "Date",
                viewControllerIdentifier: "DateViewController"
            )
        case .stats:
            return StoryboardSceneDescriptor(
                storyboardName: "Stats",
                viewControllerIdentifier: "StatsViewController"
            )
        case .settings:
            return StoryboardSceneDescriptor(
                storyboardName: "Settings",
                viewControllerIdentifier: "SettingsViewController"
            )
        case .map:
            return nil
        }
    }
}

protocol StoryboardSceneInstantiating {
    func instantiate(_ descriptor: StoryboardSceneDescriptor) -> UIViewController
}

struct UIKitStoryboardSceneInstantiator: StoryboardSceneInstantiating {
    func instantiate(_ descriptor: StoryboardSceneDescriptor) -> UIViewController {
        UIStoryboard(name: descriptor.storyboardName, bundle: nil)
            .instantiateViewController(withIdentifier: descriptor.viewControllerIdentifier)
    }
}

protocol RenewedShellDirectViewControllerProviding {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController?
}

struct LegacyRenewedShellDirectViewControllerProvider: RenewedShellDirectViewControllerProviding {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController? {
        switch tab.kind {
        case .map:
            return MapViewController()
        case .today, .timeline, .stats, .settings:
            return nil
        }
    }
}

struct StoryboardBackedRenewedShellViewControllerFactory: RenewedShellViewControllerFactory {
    private let sceneProvider: any RenewedShellStoryboardSceneProviding
    private let storyboardInstantiator: any StoryboardSceneInstantiating
    private let directViewControllerProvider: any RenewedShellDirectViewControllerProviding
    private let fallbackFactory: any RenewedShellViewControllerFactory

    init(
        sceneProvider: any RenewedShellStoryboardSceneProviding = LegacyRenewedShellStoryboardSceneProvider(),
        storyboardInstantiator: any StoryboardSceneInstantiating = UIKitStoryboardSceneInstantiator(),
        directViewControllerProvider: any RenewedShellDirectViewControllerProviding = LegacyRenewedShellDirectViewControllerProvider(),
        fallbackFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory()
    ) {
        self.sceneProvider = sceneProvider
        self.storyboardInstantiator = storyboardInstantiator
        self.directViewControllerProvider = directViewControllerProvider
        self.fallbackFactory = fallbackFactory
    }

    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        if let controller = directViewControllerProvider.makeViewController(for: tab) {
            return controller
        }

        guard let descriptor = sceneProvider.sceneDescriptor(for: tab) else {
            return fallbackFactory.makeViewController(for: tab)
        }

        return storyboardInstantiator.instantiate(descriptor)
    }
}

final class RenewedShellCoordinator {
    private let presentation: RenewedShellPresentation
    private let viewControllerFactory: any RenewedShellViewControllerFactory

    init(
        presentation: RenewedShellPresentation = .legacyStoryboardBridge,
        viewControllerFactory: any RenewedShellViewControllerFactory = StoryboardBackedRenewedShellViewControllerFactory()
    ) {
        self.presentation = presentation
        self.viewControllerFactory = viewControllerFactory
    }

    func makeRootViewController() -> UIViewController {
        RenewedShellViewController(
            presentation: presentation,
            viewControllerFactory: viewControllerFactory
        )
    }
}

protocol LegacyRootViewControllerFactory {
    func makeMainTabs() -> UITabBarController?
    func makeFirstLaunch() -> UIViewController
    func makePasswordUnlock() -> PasswordVC?
}

struct StoryboardLegacyRootViewControllerFactory: LegacyRootViewControllerFactory {
    private let storyboardInstantiator: any StoryboardSceneInstantiating

    init(storyboardInstantiator: any StoryboardSceneInstantiating = UIKitStoryboardSceneInstantiator()) {
        self.storyboardInstantiator = storyboardInstantiator
    }

    func makeMainTabs() -> UITabBarController? {
        storyboardInstantiator.instantiate(.legacyMainTabs) as? UITabBarController
    }

    func makeFirstLaunch() -> UIViewController {
        storyboardInstantiator.instantiate(.legacyFirstLaunch)
    }

    func makePasswordUnlock() -> PasswordVC? {
        storyboardInstantiator.instantiate(.legacyPasswordUnlock) as? PasswordVC
    }
}

enum SceneForegroundRoute: Equatable {
    case none
    case passwordUnlock
    case firstLaunch
}

struct SceneForegroundPlan: Equatable {
    var shouldInvalidateAlwaysOnTimer: Bool
    var route: SceneForegroundRoute
}

enum SceneWidgetTrackingAction: Equatable {
    case start
    case stop
}

struct SceneLifecycleCoordinator: Equatable {
    func foregroundPlan(userState: String?, alwaysOn: Bool) -> SceneForegroundPlan {
        if userState == "hasPassword" || userState == "hasBioId" {
            return SceneForegroundPlan(
                shouldInvalidateAlwaysOnTimer: alwaysOn,
                route: .passwordUnlock
            )
        }

        if userState == nil {
            return SceneForegroundPlan(
                shouldInvalidateAlwaysOnTimer: alwaysOn,
                route: .firstLaunch
            )
        }

        return SceneForegroundPlan(
            shouldInvalidateAlwaysOnTimer: alwaysOn,
            route: .none
        )
    }

    func isWidgetURL(_ url: URL?) -> Bool {
        url?.scheme == "widget"
    }

    func widgetTrackingAction(wasTracking: Bool) -> SceneWidgetTrackingAction {
        wasTracking ? .stop : .start
    }
}

struct FirstLaunchDefaultsInitializer {
    private let standardDefaults: UserDefaults
    private let widgetDefaults: UserDefaults?

    init(
        standardDefaults: UserDefaults = .standard,
        widgetDefaults: UserDefaults? = UserDefaults(suiteName: "group.footage")
    ) {
        self.standardDefaults = standardDefaults
        self.widgetDefaults = widgetDefaults
    }

    func apply() {
        standardDefaults.set("", forKey: "todayBadge")
        standardDefaults.set(0, forKey: "minimumTotalDistance")
        standardDefaults.set(0, forKey: "minimumTotalRecord")
        standardDefaults.set(false, forKey: "startedBefore")

        widgetDefaults?.set("노란색", forKey: "#EADE4Cff")
        widgetDefaults?.set("분홍색", forKey: "#F5A997ff")
        widgetDefaults?.set("흰  색", forKey: "#F0E7CFff")
        widgetDefaults?.set("주황색", forKey: "#FF6B39ff")
        widgetDefaults?.set("파란색", forKey: "#206491ff")
    }
}

struct SceneWidgetTrackingStateStore {
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: "group.footage")) {
        self.defaults = defaults
    }

    func toggleTracking() -> Bool? {
        guard let defaults else { return nil }
        let wasTracking = defaults.bool(forKey: "isTracking")
        defaults.set(!wasTracking, forKey: "isTracking")
        return wasTracking
    }

    func clearTracking() {
        defaults?.set(false, forKey: "isTracking")
    }
}

struct LegacyHomeTabControllerAccessor {
    func selectHomeTab(from rootViewController: UIViewController?) -> UIViewController? {
        guard let tabBarController = rootViewController as? UITabBarController else { return nil }

        tabBarController.selectedIndex = 0
        return tabBarController.viewControllers?.first
    }

    func selectHome(from rootViewController: UIViewController?) -> HomeViewController? {
        selectHomeTab(from: rootViewController) as? HomeViewController
    }
}
