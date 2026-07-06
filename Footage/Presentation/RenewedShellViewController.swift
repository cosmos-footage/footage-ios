//
//  RenewedShellViewController.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import UIKit

final class RenewedShellViewController: UITabBarController {
    private let presentation: RenewedShellPresentation
    private let viewControllerFactory: any RenewedShellViewControllerFactory

    init(
        presentation: RenewedShellPresentation = .default,
        viewControllerFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory()
    ) {
        self.presentation = presentation
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.presentation = .default
        self.viewControllerFactory = PlaceholderRenewedShellViewControllerFactory()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = presentation.tabs.map { tab in
            let controller = viewControllerFactory.makeViewController(for: tab)
            controller.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.systemImageName),
                selectedImage: UIImage(systemName: tab.systemImageName)
            )
            return controller
        }
    }
}
