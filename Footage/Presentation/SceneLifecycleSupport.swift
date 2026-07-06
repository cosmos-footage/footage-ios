//
//  SceneLifecycleSupport.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit
import WidgetKit

enum SceneForegroundRoute: Equatable {
    case none
    case passwordUnlock
    case firstLaunch
}

struct SceneForegroundPlan: Equatable {
    var shouldInvalidateAlwaysOnTimer: Bool
    var route: SceneForegroundRoute
}

struct SceneInitialConnectionPlan: Equatable {
    var shouldPrepareLegacyHome: Bool
    var shouldStartTrackingFromWidget: Bool
}

enum SceneWidgetTrackingAction: Equatable {
    case start
    case stop
}

enum SceneHomeTrackingCommand: Equatable {
    case start
    case stop
}

enum SceneBackgroundRecordingAction: Equatable {
    case none
    case scheduleAlwaysOnLocationRefresh
    case startUpdatingLocation
}

struct SceneLifecycleCoordinator: Equatable {
    func initialConnectionPlan(isWindowScene: Bool, url: URL?) -> SceneInitialConnectionPlan {
        guard isWindowScene else {
            return SceneInitialConnectionPlan(
                shouldPrepareLegacyHome: false,
                shouldStartTrackingFromWidget: false
            )
        }

        return SceneInitialConnectionPlan(
            shouldPrepareLegacyHome: true,
            shouldStartTrackingFromWidget: isWidgetURL(url)
        )
    }

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

    func homeTrackingCommand(for action: SceneWidgetTrackingAction) -> SceneHomeTrackingCommand {
        switch action {
        case .start:
            return .start
        case .stop:
            return .stop
        }
    }

    func initialHomeTrackingCommand(shouldStartFromWidget: Bool) -> SceneHomeTrackingCommand? {
        shouldStartFromWidget ? .start : nil
    }

    func backgroundRecordingAction(isRecording: Bool, alwaysOn: Bool) -> SceneBackgroundRecordingAction {
        guard isRecording else { return .none }

        return alwaysOn ? .scheduleAlwaysOnLocationRefresh : .startUpdatingLocation
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

struct SceneUserStateStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func userState() -> String? {
        defaults.string(forKey: "UserState")
    }

    func isAlwaysOnEnabled() -> Bool {
        defaults.bool(forKey: "alwaysOn")
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

protocol SceneHomeViewControllerDispatching {
    func restoreSelectedCategory(_ selectedColor: String?, on viewController: UIViewController?)
    func dispatchTrackingCommand(_ command: SceneHomeTrackingCommand, to viewController: UIViewController?)
}

struct LegacySceneHomeViewControllerDispatcher: SceneHomeViewControllerDispatching {
    func restoreSelectedCategory(_ selectedColor: String?, on viewController: UIViewController?) {
        guard let homeViewController = viewController as? HomeViewController else { return }

        homeViewController.setToLastCategory(selectedColor: selectedColor)
    }

    func dispatchTrackingCommand(_ command: SceneHomeTrackingCommand, to viewController: UIViewController?) {
        guard let homeViewController = viewController as? HomeViewController else { return }

        switch command {
        case .start:
            homeViewController.startTracking()
        case .stop:
            homeViewController.stopTracking()
        }
    }
}

protocol SceneBackgroundRecordingDispatching {
    func dispatch(
        _ action: SceneBackgroundRecordingAction,
        timerAssignment: @escaping (Timer) -> Void
    )
}

struct LegacySceneBackgroundRecordingDispatcher: SceneBackgroundRecordingDispatching {
    func dispatch(
        _ action: SceneBackgroundRecordingAction,
        timerAssignment: @escaping (Timer) -> Void
    ) {
        switch action {
        case .none:
            break
        case .scheduleAlwaysOnLocationRefresh:
            Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
                timerAssignment(timer)
                HomeViewController.locationManager.requestLocation()
            }
        case .startUpdatingLocation:
            HomeViewController.locationManager.startUpdatingLocation()
        }
    }
}

protocol SceneForegroundRouteDispatching {
    func dispatch(
        _ plan: SceneForegroundPlan,
        in window: UIWindow?,
        timerInvalidation: () -> Void
    )
}

struct LegacySceneForegroundRouteDispatcher: SceneForegroundRouteDispatching {
    private let rootViewControllerFactory: any LegacyRootViewControllerFactory
    private let fullScreenPresenter: SceneFullScreenPresenter
    private let rootControllerInstaller: SceneRootControllerInstaller
    private let firstLaunchDefaultsInitializer: FirstLaunchDefaultsInitializer

    init(
        rootViewControllerFactory: any LegacyRootViewControllerFactory = StoryboardLegacyRootViewControllerFactory(),
        fullScreenPresenter: SceneFullScreenPresenter = SceneFullScreenPresenter(),
        rootControllerInstaller: SceneRootControllerInstaller = SceneRootControllerInstaller(),
        firstLaunchDefaultsInitializer: FirstLaunchDefaultsInitializer = FirstLaunchDefaultsInitializer()
    ) {
        self.rootViewControllerFactory = rootViewControllerFactory
        self.fullScreenPresenter = fullScreenPresenter
        self.rootControllerInstaller = rootControllerInstaller
        self.firstLaunchDefaultsInitializer = firstLaunchDefaultsInitializer
    }

    func dispatch(
        _ plan: SceneForegroundPlan,
        in window: UIWindow?,
        timerInvalidation: () -> Void
    ) {
        if plan.shouldInvalidateAlwaysOnTimer {
            timerInvalidation()
        }

        switch plan.route {
        case .passwordUnlock:
            guard let passwordVC = rootViewControllerFactory.makePasswordUnlock() else { return }
            fullScreenPresenter.presentFullScreen(passwordVC, from: window?.rootViewController)
        case .firstLaunch:
            let firstLaunchVC = rootViewControllerFactory.makeFirstLaunch()
            rootControllerInstaller.installRoot(firstLaunchVC, in: window)
            firstLaunchDefaultsInitializer.apply()
        case .none:
            break
        }
    }
}

struct SceneFullScreenPresenter {
    func topViewController(from rootViewController: UIViewController?) -> UIViewController? {
        var topController = rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }

    func prepareFullScreen(_ viewController: UIViewController, screenBounds: CGRect = UIScreen.main.bounds) {
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.widthAnchor.constraint(equalToConstant: screenBounds.width).isActive = true
        viewController.view.heightAnchor.constraint(equalToConstant: screenBounds.height).isActive = true
        viewController.modalPresentationStyle = .fullScreen
    }

    func presentFullScreen(
        _ viewController: UIViewController,
        from rootViewController: UIViewController?,
        animated: Bool = false
    ) {
        guard let topController = topViewController(from: rootViewController) else { return }

        prepareFullScreen(viewController)
        topController.present(viewController, animated: animated, completion: nil)
    }
}

struct SceneRootControllerInstaller {
    func installRoot(_ viewController: UIViewController, in window: UIWindow?) {
        window?.rootViewController = viewController
    }
}

protocol SceneHomeInitialDataLoading {
    func prepareLegacyHomeData()
}

struct LegacySceneHomeInitialDataLoader: SceneHomeInitialDataLoading {
    func prepareLegacyHomeData() {
        HomeViewController.distanceTotal = DateManager.loadDistance(total: true)
        DateManager.loadTodayData()
    }
}

struct SceneSelectedColorStore {
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: "group.footage")) {
        self.defaults = defaults
    }

    func selectedColor() -> String? {
        defaults?.string(forKey: "selectedColor")
    }
}

protocol SceneWidgetTimelineReloading {
    func reloadAllTimelines()
}

struct WidgetKitSceneWidgetTimelineReloader: SceneWidgetTimelineReloading {
    func reloadAllTimelines() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
