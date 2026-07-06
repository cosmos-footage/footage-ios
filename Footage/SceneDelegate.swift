//
//  SceneDelegate.swift
//  footage
//
//  Created by 녘 on 2020/06/09.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let homeVC = HomeViewController()
    var alwaysOnTimer = Timer()
    private let rootViewControllerFactory: any LegacyRootViewControllerFactory = StoryboardLegacyRootViewControllerFactory()
    private let sceneLifecycleCoordinator = SceneLifecycleCoordinator()
    private let firstLaunchDefaultsInitializer = FirstLaunchDefaultsInitializer()
    private let widgetTrackingStateStore = SceneWidgetTrackingStateStore()
    private let homeTabAccessor = LegacyHomeTabControllerAccessor()
    private let fullScreenPresenter = SceneFullScreenPresenter()
    private let rootControllerInstaller = SceneRootControllerInstaller()
    private let widgetTimelineReloader: any SceneWidgetTimelineReloading = WidgetKitSceneWidgetTimelineReloader()
    private let homeInitialDataLoader: any SceneHomeInitialDataLoading = LegacySceneHomeInitialDataLoader()
    private let selectedColorStore = SceneSelectedColorStore()
    private let homeViewControllerDispatcher: any SceneHomeViewControllerDispatching = LegacySceneHomeViewControllerDispatcher()
    private let backgroundRecordingDispatcher: any SceneBackgroundRecordingDispatching = LegacySceneBackgroundRecordingDispatcher()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        let initialPlan = sceneLifecycleCoordinator.initialConnectionPlan(
            isWindowScene: scene is UIWindowScene,
            url: connectionOptions.urlContexts.first?.url
        )
        guard initialPlan.shouldPrepareLegacyHome else { return }

        homeInitialDataLoader.prepareLegacyHomeData()
        let homeViewController = homeTabAccessor.selectHomeTab(from: window?.rootViewController)
        homeViewControllerDispatcher.restoreSelectedCategory(
            selectedColorStore.selectedColor(),
            on: homeViewController
        )
        if let command = sceneLifecycleCoordinator.initialHomeTrackingCommand(
            shouldStartFromWidget: initialPlan.shouldStartTrackingFromWidget
        ) {
            homeViewControllerDispatcher.dispatchTrackingCommand(command, to: homeViewController)
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // TODO: started before 추가
        guard let wasTracking = widgetTrackingStateStore.toggleTracking() else { return }
        let homeViewController = homeTabAccessor.selectHomeTab(from: window?.rootViewController)
        let widgetAction = sceneLifecycleCoordinator.widgetTrackingAction(wasTracking: wasTracking)
        let command = sceneLifecycleCoordinator.homeTrackingCommand(for: widgetAction)

        homeViewControllerDispatcher.dispatchTrackingCommand(command, to: homeViewController)
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        widgetTrackingStateStore.clearTracking()
        widgetTimelineReloader.reloadAllTimelines()
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let userState = UserDefaults.standard.string(forKey: "UserState")
        let alwaysOn = UserDefaults.standard.bool(forKey: "alwaysOn")
        let foregroundPlan = sceneLifecycleCoordinator.foregroundPlan(
            userState: userState,
            alwaysOn: alwaysOn
        )
        if foregroundPlan.shouldInvalidateAlwaysOnTimer {
            alwaysOnTimer.invalidate()
        }

        switch foregroundPlan.route {
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
        // Widget Color Update
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        let backgroundAction = sceneLifecycleCoordinator.backgroundRecordingAction(
            isRecording: HomeViewController.currentStartButtonImage == #imageLiteral(resourceName: "stopButton"),
            alwaysOn: UserDefaults.standard.bool(forKey: "alwaysOn")
        )
        backgroundRecordingDispatcher.dispatch(backgroundAction) { [weak self] timer in
            self?.alwaysOnTimer = timer
        }
        widgetTimelineReloader.reloadAllTimelines()
    }
}
