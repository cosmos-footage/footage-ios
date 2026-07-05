//
//  UseCases.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import Foundation

struct HomeDashboardSnapshot: Equatable {
    var distanceTodayMeters: Double
    var distanceTotalMeters: Double
    var isTracking: Bool
    var selectedColorCategoryId: String?
    var generatedAt: Date
}

protocol HomeDashboardUseCase {
    func loadSnapshot() -> HomeDashboardSnapshot
}

final class DefaultHomeDashboardUseCase: HomeDashboardUseCase {
    private let daySummaryRepository: DaySummaryRepository
    private let widgetStateStore: WidgetStateStore?
    private let now: () -> Date

    init(
        daySummaryRepository: DaySummaryRepository,
        widgetStateStore: WidgetStateStore?,
        now: @escaping () -> Date = Date.init
    ) {
        self.daySummaryRepository = daySummaryRepository
        self.widgetStateStore = widgetStateStore
        self.now = now
    }

    func loadSnapshot() -> HomeDashboardSnapshot {
        HomeDashboardSnapshot(
            distanceTodayMeters: daySummaryRepository.loadDistance(total: false),
            distanceTotalMeters: daySummaryRepository.loadDistance(total: true),
            isTracking: widgetStateStore?.isTracking ?? false,
            selectedColorCategoryId: widgetStateStore?.selectedColor,
            generatedAt: now()
        )
    }
}

enum DateTimelineRange: String, Equatable {
    case day
    case month
    case year
}

protocol DateTimelineUseCase {
    func loadTimeline(range: DateTimelineRange) -> [JourneyEntity]
}

final class DefaultDateTimelineUseCase: DateTimelineUseCase {
    private let routeRepository: RouteRepository

    init(routeRepository: RouteRepository) {
        self.routeRepository = routeRepository
    }

    func loadTimeline(range: DateTimelineRange) -> [JourneyEntity] {
        routeRepository.loadJourneys(rangeOf: range.rawValue).map { journey in
            let mediaCount = journey.footsteps.reduce(0) { $0 + $1.photos.count }
            let noteCount = journey.footsteps.reduce(0) { total, footstep in
                total + footstep.notes.filter { !$0.isEmpty }.count
            }
            let distance = (journey.reference as? DayData)?.distance ?? 0

            return JourneyEntity(
                recordingId: RecordingID(rawValue: "legacy-\(journey.date)"),
                localDate: String(journey.date),
                startedAt: journey.footsteps.first?.timestamp ?? Date(timeIntervalSince1970: 0),
                endedAt: journey.footsteps.last?.timestamp,
                distanceMeters: distance,
                pointCount: journey.footsteps.count,
                primaryColorCategoryId: journey.footsteps.first?.color,
                mediaCount: mediaCount,
                noteCount: noteCount,
                syncStatus: .localOnly
            )
        }
    }
}

struct StatsOverviewSnapshot: Equatable {
    var distanceTodayMeters: Double
    var distanceTotalMeters: Double
    var distanceThisMonthMeters: Double
    var topColorCategoryId: String?
    var topPlaceName: String?
    var generatedAt: Date
}

protocol StatsOverviewUseCase {
    func loadOverview(todayKey: Int, monthStartKey: Int, monthEndKey: Int) -> StatsOverviewSnapshot
}

final class DefaultStatsOverviewUseCase: StatsOverviewUseCase {
    private let daySummaryRepository: DaySummaryRepository
    private let colorRepository: ColorRepository
    private let placeRepository: PlaceRepository
    private let now: () -> Date

    init(
        daySummaryRepository: DaySummaryRepository,
        colorRepository: ColorRepository,
        placeRepository: PlaceRepository,
        now: @escaping () -> Date = Date.init
    ) {
        self.daySummaryRepository = daySummaryRepository
        self.colorRepository = colorRepository
        self.placeRepository = placeRepository
        self.now = now
    }

    func loadOverview(todayKey: Int, monthStartKey: Int, monthEndKey: Int) -> StatsOverviewSnapshot {
        StatsOverviewSnapshot(
            distanceTodayMeters: daySummaryRepository.loadDistance(total: false),
            distanceTotalMeters: daySummaryRepository.loadDistance(total: true),
            distanceThisMonthMeters: daySummaryRepository.loadMonthlyDistance(),
            topColorCategoryId: colorRepository.rankingDistance(startDate: monthStartKey, endDate: monthEndKey).first?.key,
            topPlaceName: placeRepository.rankingDistance(startDate: monthStartKey, endDate: monthEndKey).first?.key,
            generatedAt: now()
        )
    }
}

protocol BackupPreparationUseCase {
    func status() -> LocalBackupStatus
    func prepare(configuration: SyncBatchConfiguration) throws -> ManualBackupPreparationResult
}

final class DefaultBackupPreparationUseCase: BackupPreparationUseCase {
    private let runner: ManualCloudBackupRunning

    init(runner: ManualCloudBackupRunning) {
        self.runner = runner
    }

    func status() -> LocalBackupStatus {
        runner.localBackupStatus()
    }

    func prepare(configuration: SyncBatchConfiguration = SyncBatchConfiguration()) throws -> ManualBackupPreparationResult {
        try runner.prepareLocalRouteBackup(configuration: configuration)
    }
}

protocol RestorePreviewUseCase {
    func status() -> RestoreStatus
    func previewLocalManifest(
        _ manifest: RestoreManifestResponse,
        routeObjectData: [Data],
        conflictPolicy: RestoreConflictPolicy
    ) -> Result<RestorePreview, Error>
}

final class DefaultRestorePreviewUseCase: RestorePreviewUseCase {
    private let restoreService: RestoreService

    init(restoreService: RestoreService) {
        self.restoreService = restoreService
    }

    func status() -> RestoreStatus {
        restoreService.status
    }

    func previewLocalManifest(
        _ manifest: RestoreManifestResponse,
        routeObjectData: [Data],
        conflictPolicy: RestoreConflictPolicy = .skipExisting
    ) -> Result<RestorePreview, Error> {
        restoreService.previewLocalManifest(
            manifest,
            routeObjectData: routeObjectData,
            conflictPolicy: conflictPolicy
        )
    }
}

struct AuthLinkingReadinessSnapshot: Equatable {
    var ownerId: OwnerID?
    var authLinkState: AuthLinkState
    var isAuthFeatureEnabled: Bool

    var canStartLinking: Bool {
        isAuthFeatureEnabled && ownerId != nil && authLinkState != .linking
    }
}

protocol AuthLinkingReadinessUseCase {
    func snapshot() -> AuthLinkingReadinessSnapshot
}

final class DefaultAuthLinkingReadinessUseCase: AuthLinkingReadinessUseCase {
    private let identityRepository: DeviceIdentityRepository
    private let authIdentityStore: AuthIdentityStore
    private let isAuthFeatureEnabled: () -> Bool

    init(
        identityRepository: DeviceIdentityRepository,
        authIdentityStore: AuthIdentityStore,
        isAuthFeatureEnabled: @escaping () -> Bool
    ) {
        self.identityRepository = identityRepository
        self.authIdentityStore = authIdentityStore
        self.isAuthFeatureEnabled = isAuthFeatureEnabled
    }

    func snapshot() -> AuthLinkingReadinessSnapshot {
        AuthLinkingReadinessSnapshot(
            ownerId: identityRepository.ownerId(),
            authLinkState: authIdentityStore.state(),
            isAuthFeatureEnabled: isAuthFeatureEnabled()
        )
    }
}

protocol CloudBackupSettingsRepository {
    var isOptedIn: Bool { get set }
}

extension CloudBackupSettingsStore: CloudBackupSettingsRepository {}

struct SettingsPreferencesSnapshot: Equatable {
    var isCloudBackupOptedIn: Bool
    var featureFlags: FeatureFlags
}

protocol SettingsPreferencesUseCase {
    func loadPreferences() -> SettingsPreferencesSnapshot
    func setCloudBackupOptIn(_ isOptedIn: Bool)
}

final class DefaultSettingsPreferencesUseCase: SettingsPreferencesUseCase {
    private var settingsRepository: CloudBackupSettingsRepository
    private let featureFlags: () -> FeatureFlags

    init(
        settingsRepository: CloudBackupSettingsRepository,
        featureFlags: @escaping () -> FeatureFlags
    ) {
        self.settingsRepository = settingsRepository
        self.featureFlags = featureFlags
    }

    func loadPreferences() -> SettingsPreferencesSnapshot {
        SettingsPreferencesSnapshot(
            isCloudBackupOptedIn: settingsRepository.isOptedIn,
            featureFlags: featureFlags()
        )
    }

    func setCloudBackupOptIn(_ isOptedIn: Bool) {
        settingsRepository.isOptedIn = isOptedIn
    }
}

protocol RecordingLifecycleUseCase {
    func transition(
        from state: RecordingLifecycleState,
        event: RecordingStateTransitionPolicy.Event
    ) -> Result<RecordingLifecycleState, RecordingStateTransitionPolicy.RejectionReason>
}

final class DefaultRecordingLifecycleUseCase: RecordingLifecycleUseCase {
    private let policy: RecordingStateTransitionPolicy

    init(policy: RecordingStateTransitionPolicy = RecordingStateTransitionPolicy()) {
        self.policy = policy
    }

    func transition(
        from state: RecordingLifecycleState,
        event: RecordingStateTransitionPolicy.Event
    ) -> Result<RecordingLifecycleState, RecordingStateTransitionPolicy.RejectionReason> {
        policy.transition(from: state, event: event)
    }
}
