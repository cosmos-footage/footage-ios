//
//  AppRootViewControllerFactory.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

protocol AppRootViewControllerMaking {
    func makeRootViewController(for route: AppRootRoute) -> UIViewController?
}

struct AppRootViewControllerFactory: AppRootViewControllerMaking {
    private let legacyRootFactory: any LegacyRootViewControllerFactory
    private let renewedShellRootFactory: () -> UIViewController

    init(
        legacyRootFactory: any LegacyRootViewControllerFactory = StoryboardLegacyRootViewControllerFactory(),
        renewedShellRootFactory: @escaping () -> UIViewController = {
            RenewedShellCoordinator(
                presentation: .default,
                viewControllerFactory: ProgrammaticRenewedShellViewControllerFactory()
            ).makeRootViewController()
        }
    ) {
        self.legacyRootFactory = legacyRootFactory
        self.renewedShellRootFactory = renewedShellRootFactory
    }

    func makeRootViewController(for route: AppRootRoute) -> UIViewController? {
        switch route.destination {
        case .legacyFirstLaunch:
            return legacyRootFactory.makeFirstLaunch()
        case .legacyMainTabs:
            return legacyRootFactory.makeMainTabs()
        case .renewedUIKitShell:
            return renewedShellRootFactory()
        }
    }
}
