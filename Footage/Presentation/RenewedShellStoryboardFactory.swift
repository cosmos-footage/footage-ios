//
//  RenewedShellStoryboardFactory.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import UIKit

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
