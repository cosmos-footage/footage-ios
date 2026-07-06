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
    private let mapViewController: (() -> UIViewController)?
    private let statsOverview: (() -> StatsOverviewSnapshot)?
    private let timelineJourneys: (() -> [JourneyEntity])?
    private let settingsPreferencesUseCase: (() -> SettingsPreferencesUseCase)?
    private let backupPreparationUseCase: (() -> BackupPreparationUseCase)?
    private let restorePreviewUseCase: (() -> RestorePreviewUseCase)?
    private let authLinkingReadinessUseCase: (() -> AuthLinkingReadinessUseCase)?
    private let legacyVersionCode: (() -> Int)?

    init(
        placeholderFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory(),
        homeDashboardUseCase: (() -> HomeDashboardUseCase)? = nil,
        mapViewController: (() -> UIViewController)? = nil,
        statsOverview: (() -> StatsOverviewSnapshot)? = nil,
        timelineJourneys: (() -> [JourneyEntity])? = nil,
        settingsPreferencesUseCase: (() -> SettingsPreferencesUseCase)? = nil,
        backupPreparationUseCase: (() -> BackupPreparationUseCase)? = nil,
        restorePreviewUseCase: (() -> RestorePreviewUseCase)? = nil,
        authLinkingReadinessUseCase: (() -> AuthLinkingReadinessUseCase)? = nil,
        legacyVersionCode: (() -> Int)? = nil
    ) {
        self.placeholderFactory = placeholderFactory
        self.homeDashboardUseCase = homeDashboardUseCase
        self.mapViewController = mapViewController
        self.statsOverview = statsOverview
        self.timelineJourneys = timelineJourneys
        self.settingsPreferencesUseCase = settingsPreferencesUseCase
        self.backupPreparationUseCase = backupPreparationUseCase
        self.restorePreviewUseCase = restorePreviewUseCase
        self.authLinkingReadinessUseCase = authLinkingReadinessUseCase
        self.legacyVersionCode = legacyVersionCode
    }

    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        if tab.kind == .today, let homeDashboardUseCase = homeDashboardUseCase {
            return RenewedTodayDashboardViewController {
                homeDashboardUseCase().loadSnapshot()
            }
        }

        if tab.kind == .map, let mapViewController = mapViewController {
            return mapViewController()
        }

        if tab.kind == .stats, let statsOverview = statsOverview {
            return RenewedStatsOverviewViewController(loadSnapshot: statsOverview)
        }

        if tab.kind == .timeline, let timelineJourneys = timelineJourneys {
            return RenewedTimelineViewController(loadJourneys: timelineJourneys)
        }

        if tab.kind == .settings, let settingsPreferencesUseCase = settingsPreferencesUseCase {
            return RenewedSettingsDashboardViewController(
                loadSnapshot: {
                    settingsPreferencesUseCase().loadPreferences()
                },
                makeBackupStatusViewController: backupPreparationUseCase.map { backupPreparationUseCase in
                    {
                        RenewedBackupStatusViewController(backupPreparationUseCase: backupPreparationUseCase())
                    }
                },
                makeRestoreStatusViewController: restorePreviewUseCase.map { restorePreviewUseCase in
                    {
                        RenewedRestoreStatusViewController(restorePreviewUseCase: restorePreviewUseCase())
                    }
                },
                makeAuthReadinessViewController: authLinkingReadinessUseCase.map { authLinkingReadinessUseCase in
                    {
                        RenewedAuthReadinessViewController(authLinkingReadinessUseCase: authLinkingReadinessUseCase())
                    }
                },
                makeAboutViewController: legacyVersionCode.map { legacyVersionCode in
                    {
                        RenewedAboutViewController(
                            legacyVersionCode: legacyVersionCode,
                            makePrivacyPolicyViewController: {
                                RenewedPrivacyPolicyViewController()
                            },
                            contactMailPresenter: RenewedContactMailPresenter()
                        )
                    }
                }
            )
        }

        return placeholderFactory.makeViewController(for: tab)
    }
}
