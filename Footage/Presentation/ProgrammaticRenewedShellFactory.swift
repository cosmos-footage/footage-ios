//
//  ProgrammaticRenewedShellFactory.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

struct ProgrammaticRenewedShellViewControllerFactory: RenewedShellViewControllerFactory {
    private let placeholderFactory: any RenewedShellViewControllerFactory

    init(placeholderFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory()) {
        self.placeholderFactory = placeholderFactory
    }

    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        placeholderFactory.makeViewController(for: tab)
    }
}
