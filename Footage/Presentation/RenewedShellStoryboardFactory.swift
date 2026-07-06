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
