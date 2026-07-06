//
//  RenewedShellCoordinator.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

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
