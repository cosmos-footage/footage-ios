//
//  SceneDelegate.swift
//  footage
//
//  Created by 녘 on 2020/06/09.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    let homeVC = HomeViewController()
    var alwaysOnTimer = Timer()
    private let rootViewControllerFactory: any LegacyRootViewControllerFactory = StoryboardLegacyRootViewControllerFactory()
    private let sceneLifecycleCoordinator = SceneLifecycleCoordinator()
    private let firstLaunchDefaultsInitializer = FirstLaunchDefaultsInitializer()
    private let widgetTrackingStateStore = SceneWidgetTrackingStateStore()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        HomeViewController.distanceTotal = DateManager.loadDistance(total: true)
        DateManager.loadTodayData()
        guard let tabBarVC = window?.rootViewController as? UITabBarController else { return }
        tabBarVC.selectedIndex = 0
        guard let homeVC = tabBarVC.selectedViewController as? HomeViewController else { return }
        homeVC.setToLastCategory(selectedColor: UserDefaults(suiteName: "group.footage")?.string(forKey: "selectedColor"))
        if sceneLifecycleCoordinator.isWidgetURL(connectionOptions.urlContexts.first?.url) {
            homeVC.startTracking()
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // TODO: started before 추가
        guard let wasTracking = widgetTrackingStateStore.toggleTracking() else { return }
        if let tabBarVC = window?.rootViewController as? UITabBarController {
            tabBarVC.selectedIndex = 0
            if let homeVC = tabBarVC.selectedViewController as? HomeViewController {
                switch sceneLifecycleCoordinator.widgetTrackingAction(wasTracking: wasTracking) {
                case .start:
                    homeVC.startTracking()
                case .stop:
                    homeVC.stopTracking()
                }
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
        widgetTrackingStateStore.clearTracking()
        WidgetCenter.shared.reloadAllTimelines()
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
            if var topController = window?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                let screenSize = UIScreen.main.bounds
                passwordVC.view.translatesAutoresizingMaskIntoConstraints = false
                passwordVC.view.widthAnchor.constraint(equalToConstant: screenSize.width).isActive = true
                passwordVC.view.heightAnchor.constraint(equalToConstant: screenSize.height).isActive = true
                passwordVC.modalPresentationStyle = .fullScreen
                topController.present(passwordVC, animated: false, completion: nil)
            }
        case .firstLaunch:
            let firstLaunchVC = rootViewControllerFactory.makeFirstLaunch()
            self.window?.rootViewController = firstLaunchVC
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
        if HomeViewController.currentStartButtonImage == #imageLiteral(resourceName: "stopButton") {
            let alwaysOn = UserDefaults.standard.bool(forKey: "alwaysOn")
            if alwaysOn {
                Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { timer in
                    self.alwaysOnTimer = timer
                    HomeViewController.locationManager.requestLocation()
                }
            } else {
                HomeViewController.locationManager.startUpdatingLocation()
                
            }
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
