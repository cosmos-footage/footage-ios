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
    private let areReadOnlySettingsDetailRoutesEnabled: Bool

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
        legacyVersionCode: (() -> Int)? = nil,
        areReadOnlySettingsDetailRoutesEnabled: Bool = false
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
        self.areReadOnlySettingsDetailRoutesEnabled = areReadOnlySettingsDetailRoutesEnabled
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
                makeBackupStatusViewController: readOnlySettingsDetailRoute(backupPreparationUseCase) { backupPreparationUseCase in
                    {
                        RenewedBackupStatusViewController(backupPreparationUseCase: backupPreparationUseCase())
                    }
                },
                makeRestoreStatusViewController: readOnlySettingsDetailRoute(restorePreviewUseCase) { restorePreviewUseCase in
                    {
                        RenewedRestoreStatusViewController(restorePreviewUseCase: restorePreviewUseCase())
                    }
                },
                makeAuthReadinessViewController: readOnlySettingsDetailRoute(authLinkingReadinessUseCase) { authLinkingReadinessUseCase in
                    {
                        RenewedAuthReadinessViewController(authLinkingReadinessUseCase: authLinkingReadinessUseCase())
                    }
                },
                makeAboutViewController: readOnlySettingsDetailRoute(legacyVersionCode) { legacyVersionCode in
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

    private func readOnlySettingsDetailRoute<Dependency>(
        _ dependency: Dependency?,
        makeFactory: (Dependency) -> (() -> UIViewController)
    ) -> (() -> UIViewController)? {
        guard areReadOnlySettingsDetailRoutesEnabled, let dependency = dependency else {
            return nil
        }

        return makeFactory(dependency)
    }
}
