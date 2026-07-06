//
//  AppCompositionRoot.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct AppCompositionRoot {
    let environment: AppEnvironment

    init(environment: AppEnvironment = .current) {
        self.environment = environment
    }

    func makeCloudBackupConfiguration() -> CloudBackupConfiguration {
        return CloudBackupConfiguration(
            baseURL: environment.cloudBackupBaseURL,
            isCloudBackupEnabled: environment.featureFlags.isCloudBackupEnabled,
            isDevelopmentUploadEnabled: environment.featureFlags.isDevelopmentUploadEnabled,
            requestTimeout: environment.cloudBackupRequestTimeout,
            schemaVersion: environment.cloudBackupSchemaVersion
        )
    }

    func makeRestoreConfiguration() -> CloudBackupConfiguration {
        return makeCloudBackupConfiguration(
            isCloudBackupEnabled: environment.featureFlags.isCloudBackupEnabled
                && environment.featureFlags.isRestoreEnabled,
            isDevelopmentUploadEnabled: false
        )
    }

    func makeAuthConfiguration() -> CloudBackupConfiguration {
        return makeCloudBackupConfiguration(
            isCloudBackupEnabled: environment.featureFlags.isCloudBackupEnabled
                && environment.featureFlags.isAuthEnabled,
            isDevelopmentUploadEnabled: false
        )
    }

    func makeCloudBackupService(
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        syncOutboxRepository: SyncOutboxRepository = LocalSyncOutboxRepository(),
        tokenStore: CloudBackupTokenStore = KeychainCloudBackupTokenStore(),
        payloadStager: BackupPayloadStager = FileBackedBackupPayloadStager()
    ) -> CloudBackupService {
        let configuration = makeCloudBackupConfiguration()
        return CloudBackupService(
            configuration: configuration,
            apiClient: apiClient,
            identityRepository: identityRepository,
            syncOutboxRepository: syncOutboxRepository,
            tokenStore: tokenStore,
            payloadStager: payloadStager
        )
    }

    func makeManualCloudBackupRunner(
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        migrationExportRepository: MigrationExportRepository = RealmMigrationExportRepository(),
        syncOutboxRepository: SyncOutboxRepository = LocalSyncOutboxRepository()
    ) -> ManualCloudBackupRunning {
        return ManualCloudBackupRunner(
            identityRepository: identityRepository,
            migrationExportRepository: migrationExportRepository,
            syncOutboxRepository: syncOutboxRepository
        )
    }

    func makeRestoreService(
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        parser: RoutePointRestoreParser = RoutePointRestoreParser(),
        importRepository: RestoreImportRepository = LocalRestoreImportRepository()
    ) -> RestoreService {
        let configuration = makeRestoreConfiguration()
        return RestoreService(
            configuration: configuration,
            apiClient: apiClient,
            identityRepository: identityRepository,
            parser: parser,
            importRepository: importRepository
        )
    }

    func makeAuthLinkingService(
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        authIdentityStore: AuthIdentityStore = LocalAuthIdentityStore()
    ) -> AuthLinkingService {
        let configuration = makeAuthConfiguration()
        return AuthLinkingService(
            configuration: configuration,
            apiClient: apiClient,
            identityRepository: identityRepository,
            authIdentityStore: authIdentityStore
        )
    }

    func makeRecordingUseCase(
        routeRepository: RouteRepository = RealmRouteRepository(),
        colorRepository: ColorRepository = RealmColorRepository(),
        placeRepository: PlaceRepository = RealmPlaceRepository(),
        widgetStateWriter: RecordingWidgetStateWriting = RecordingStateStore(),
        selectedColorProvider: @escaping () -> String,
        isAlwaysOnProvider: @escaping () -> Bool,
        alwaysOnCountProvider: @escaping () -> Int,
        alwaysOnCountSetter: @escaping (Int) -> Void
    ) -> RecordingUseCase {
        return RecordingService(
            routeRepository: routeRepository,
            colorRepository: colorRepository,
            placeRepository: placeRepository,
            widgetStateWriter: widgetStateWriter,
            selectedColorProvider: selectedColorProvider,
            isAlwaysOnProvider: isAlwaysOnProvider,
            alwaysOnCountProvider: alwaysOnCountProvider,
            alwaysOnCountSetter: alwaysOnCountSetter
        )
    }

    func makeHomeDashboardUseCase(
        daySummaryRepository: DaySummaryRepository = RealmDaySummaryRepository(),
        widgetStateStore: WidgetStateStore? = AppGroupWidgetStateStore()
    ) -> HomeDashboardUseCase {
        DefaultHomeDashboardUseCase(
            daySummaryRepository: daySummaryRepository,
            widgetStateStore: widgetStateStore
        )
    }

    func makeDateTimelineUseCase(
        routeRepository: RouteRepository = RealmRouteRepository()
    ) -> DateTimelineUseCase {
        DefaultDateTimelineUseCase(routeRepository: routeRepository)
    }

    func makeStatsOverviewUseCase(
        daySummaryRepository: DaySummaryRepository = RealmDaySummaryRepository(),
        colorRepository: ColorRepository = RealmColorRepository(),
        placeRepository: PlaceRepository = RealmPlaceRepository()
    ) -> StatsOverviewUseCase {
        DefaultStatsOverviewUseCase(
            daySummaryRepository: daySummaryRepository,
            colorRepository: colorRepository,
            placeRepository: placeRepository
        )
    }

    func makeBackupPreparationUseCase(
        runner: ManualCloudBackupRunning? = nil
    ) -> BackupPreparationUseCase {
        DefaultBackupPreparationUseCase(
            runner: runner ?? makeManualCloudBackupRunner()
        )
    }

    func makeRestorePreviewUseCase(
        restoreService: RestoreService? = nil
    ) -> RestorePreviewUseCase {
        DefaultRestorePreviewUseCase(
            restoreService: restoreService ?? makeRestoreService()
        )
    }

    func makeAuthLinkingReadinessUseCase(
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        authIdentityStore: AuthIdentityStore = LocalAuthIdentityStore()
    ) -> AuthLinkingReadinessUseCase {
        DefaultAuthLinkingReadinessUseCase(
            identityRepository: identityRepository,
            authIdentityStore: authIdentityStore,
            isAuthFeatureEnabled: { environment.featureFlags.isAuthEnabled }
        )
    }

    func makeSettingsPreferencesUseCase(
        settingsRepository: CloudBackupSettingsRepository = CloudBackupSettingsStore()
    ) -> SettingsPreferencesUseCase {
        DefaultSettingsPreferencesUseCase(
            settingsRepository: settingsRepository,
            featureFlags: { environment.featureFlags }
        )
    }

    func makeRecordingLifecycleUseCase() -> RecordingLifecycleUseCase {
        DefaultRecordingLifecycleUseCase()
    }

    func makeAppRootRouter() -> AppRootRouter {
        AppRootRouter(featureFlags: environment.featureFlags)
    }

    func makeAppRootViewControllerFactory(
        legacyRootFactory: any LegacyRootViewControllerFactory = StoryboardLegacyRootViewControllerFactory()
    ) -> AppRootViewControllerMaking {
        AppRootViewControllerFactory(
            legacyRootFactory: legacyRootFactory,
            renewedShellRootFactory: {
                RenewedShellCoordinator(
                    presentation: .default,
                    viewControllerFactory: ProgrammaticRenewedShellViewControllerFactory(
                        homeDashboardUseCase: {
                            self.makeHomeDashboardUseCase()
                        },
                        mapViewController: {
                            RenewedMapViewController()
                        },
                        statsOverview: {
                            let days = DateConverter.lastMondayToday()
                            return self.makeStatsOverviewUseCase().loadOverview(
                                todayKey: days.1,
                                monthStartKey: days.0,
                                monthEndKey: days.1
                            )
                        },
                        timelineJourneys: {
                            self.makeDateTimelineUseCase().loadTimeline(range: .day)
                        },
                        settingsPreferencesUseCase: {
                            self.makeSettingsPreferencesUseCase()
                        },
                        backupPreparationUseCase: {
                            self.makeBackupPreparationUseCase()
                        },
                        restorePreviewUseCase: {
                            self.makeRestorePreviewUseCase()
                        }
                    )
                ).makeRootViewController()
            }
        )
    }

    private func makeCloudBackupConfiguration(
        isCloudBackupEnabled: Bool,
        isDevelopmentUploadEnabled: Bool
    ) -> CloudBackupConfiguration {
        return CloudBackupConfiguration(
            baseURL: environment.cloudBackupBaseURL,
            isCloudBackupEnabled: isCloudBackupEnabled,
            isDevelopmentUploadEnabled: isDevelopmentUploadEnabled,
            requestTimeout: environment.cloudBackupRequestTimeout,
            schemaVersion: environment.cloudBackupSchemaVersion
        )
    }
}
