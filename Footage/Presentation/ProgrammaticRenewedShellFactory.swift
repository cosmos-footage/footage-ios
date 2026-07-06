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
    private let statsOverview: (() -> StatsOverviewSnapshot)?
    private let timelineJourneys: (() -> [JourneyEntity])?
    private let settingsPreferencesUseCase: (() -> SettingsPreferencesUseCase)?

    init(
        placeholderFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory(),
        homeDashboardUseCase: (() -> HomeDashboardUseCase)? = nil,
        statsOverview: (() -> StatsOverviewSnapshot)? = nil,
        timelineJourneys: (() -> [JourneyEntity])? = nil,
        settingsPreferencesUseCase: (() -> SettingsPreferencesUseCase)? = nil
    ) {
        self.placeholderFactory = placeholderFactory
        self.homeDashboardUseCase = homeDashboardUseCase
        self.statsOverview = statsOverview
        self.timelineJourneys = timelineJourneys
        self.settingsPreferencesUseCase = settingsPreferencesUseCase
    }

    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        if tab.kind == .today, let homeDashboardUseCase = homeDashboardUseCase {
            return RenewedTodayDashboardViewController {
                homeDashboardUseCase().loadSnapshot()
            }
        }

        if tab.kind == .stats, let statsOverview = statsOverview {
            return RenewedStatsOverviewViewController(loadSnapshot: statsOverview)
        }

        if tab.kind == .timeline, let timelineJourneys = timelineJourneys {
            return RenewedTimelineViewController(loadJourneys: timelineJourneys)
        }

        if tab.kind == .settings, let settingsPreferencesUseCase = settingsPreferencesUseCase {
            return RenewedSettingsDashboardViewController {
                settingsPreferencesUseCase().loadPreferences()
            }
        }

        return placeholderFactory.makeViewController(for: tab)
    }
}
