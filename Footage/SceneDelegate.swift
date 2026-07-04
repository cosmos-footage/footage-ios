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
        if let url = connectionOptions.urlContexts.first?.url {
            if url.scheme == "widget" {
                homeVC.startTracking()
            }
        }
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        // TODO: started before 추가
        guard let userDefault = UserDefaults(suiteName: "group.footage") else { return }
        let wasTracking = userDefault.bool(forKey: "isTracking")
        userDefault.set(!wasTracking, forKey: "isTracking")
        if let tabBarVC = window?.rootViewController as? UITabBarController {
            tabBarVC.selectedIndex = 0
            if let homeVC = tabBarVC.selectedViewController as? HomeViewController {
                if !wasTracking {
                    homeVC.startTracking()
                } else {
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
        UserDefaults(suiteName: "group.footage")?.set(false, forKey: "isTracking")
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
        if alwaysOn {
            alwaysOnTimer.invalidate()
        }
        if userState == "hasPassword" || userState == "hasBioId"  {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let passwordVC = storyBoard.instantiateViewController(withIdentifier: "PasswordVC") as! PasswordVC
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
        } else if userState == nil { // first launch
            let storyBoard = UIStoryboard(name: "FirstLaunch", bundle: nil)
            let firstLaunchVC = storyBoard.instantiateViewController(withIdentifier: "FL_VideoVC") as! FL_VideoVC
            self.window?.rootViewController = firstLaunchVC
            UserDefaults.standard.set("", forKey: "todayBadge")
            UserDefaults.standard.set(0, forKey: "minimumTotalDistance")
            UserDefaults.standard.set(0, forKey: "minimumTotalRecord")
            UserDefaults.standard.set(false, forKey: "startedBefore")
            guard let widgetUD = UserDefaults(suiteName: "group.footage") else { return }
            widgetUD.set("노란색", forKey: "#EADE4Cff")
            widgetUD.set("분홍색", forKey: "#F5A997ff")
            widgetUD.set("흰  색", forKey: "#F0E7CFff")
            widgetUD.set("주황색", forKey: "#FF6B39ff")
            widgetUD.set("파란색", forKey: "#206491ff")
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
