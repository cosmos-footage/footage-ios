//
//  FL_LetsStartVC.swift
//  footage
//
//  Created by 녘 on 2020/07/13.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit

class FL_LetsStartVC: UIViewController {
    private let rootViewControllerFactory: any LegacyRootViewControllerFactory = StoryboardLegacyRootViewControllerFactory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set("noPassword", forKey: "UserState")
        guard let tabBarController = rootViewControllerFactory.makeMainTabs() else { return }
        view.window?.rootViewController = tabBarController
    }
}
