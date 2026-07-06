//
//  ProgrammaticRenewedShellFactory.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

struct ProgrammaticRenewedShellViewControllerFactory: RenewedShellViewControllerFactory {
    private let placeholderFactory: any RenewedShellViewControllerFactory
    private let homeDashboardUseCase: (() -> HomeDashboardUseCase)?

    init(
        placeholderFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory(),
        homeDashboardUseCase: (() -> HomeDashboardUseCase)? = nil
    ) {
        self.placeholderFactory = placeholderFactory
        self.homeDashboardUseCase = homeDashboardUseCase
    }

    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        if tab.kind == .today, let homeDashboardUseCase = homeDashboardUseCase {
            return RenewedTodayDashboardViewController {
                homeDashboardUseCase().loadSnapshot()
            }
        }

        return placeholderFactory.makeViewController(for: tab)
    }
}
