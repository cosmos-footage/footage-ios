//
//  UseCasesTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/05.
//

import RealmSwift
import XCTest
@testable import footage

final class UseCasesTests: XCTestCase {
    func testHomeDashboardUseCaseLoadsReadOnlySnapshot() {
        let repository = FakeDaySummaryRepository(
            distanceToday: 120,
            distanceTotal: 1_200,
            monthlyDistance: 500
        )
        let widget = FakeWidgetStateStore(
            isTracking: true,
            distanceToday: 99,
            distanceTotal: 999,
            selectedColor: "#EADE4Cff"
        )
        let useCase = DefaultHomeDashboardUseCase(
            daySummaryRepository: repository,
            widgetStateStore: widget,
            now: { Date(timeIntervalSince1970: 100) }
        )

        let snapshot = useCase.loadSnapshot()

        XCTAssertEqual(snapshot.distanceTodayMeters, 120)
        XCTAssertEqual(snapshot.distanceTotalMeters, 1_200)
        XCTAssertTrue(snapshot.isTracking)
        XCTAssertEqual(snapshot.selectedColorCategoryId, "#EADE4Cff")
        XCTAssertEqual(snapshot.generatedAt, Date(timeIntervalSince1970: 100))
    }

    func testStatsOverviewUseCaseUsesRepositoryRankings() {
        let useCase = DefaultStatsOverviewUseCase(
            daySummaryRepository: FakeDaySummaryRepository(
                distanceToday: 10,
                distanceTotal: 100,
                monthlyDistance: 50
            ),
            colorRepository: FakeColorRepository(ranking: [("yellow", 10)]),
            placeRepository: FakePlaceRepository(ranking: [("Seoul", 30)]),
            now: { Date(timeIntervalSince1970: 200) }
        )

        let snapshot = useCase.loadOverview(todayKey: 20260705, monthStartKey: 20260701, monthEndKey: 20260731)

        XCTAssertEqual(snapshot.distanceTodayMeters, 10)
        XCTAssertEqual(snapshot.distanceTotalMeters, 100)
        XCTAssertEqual(snapshot.distanceThisMonthMeters, 50)
        XCTAssertEqual(snapshot.topColorCategoryId, "yellow")
        XCTAssertEqual(snapshot.topPlaceName, "Seoul")
        XCTAssertEqual(snapshot.generatedAt, Date(timeIntervalSince1970: 200))
    }

    func testBackupPreparationUseCaseWrapsManualRunner() throws {
        let runner = FakeManualCloudBackupRunner(
            result: ManualBackupPreparationResult(
                preparedItemCount: 2,
                localBackupStatus: LocalBackupStatus(
                    pendingCount: 2,
                    failedCount: 0,
                    lastPreparedAt: Date(timeIntervalSince1970: 1),
                    lastError: nil
                )
            )
        )
        let useCase = DefaultBackupPreparationUseCase(runner: runner)

        let result = try useCase.prepare(configuration: SyncBatchConfiguration(maxPointsPerBatch: 10))

        XCTAssertEqual(result.preparedItemCount, 2)
        XCTAssertEqual(useCase.status().pendingCount, 2)
    }

    func testAuthReadinessRequiresFeatureFlagAndOwner() {
        let identity = FakeDeviceIdentityRepository(ownerId: OwnerID(rawValue: "own_1"))
        let store = FakeAuthIdentityStore(state: .anonymous)
        let enabled = DefaultAuthLinkingReadinessUseCase(
            identityRepository: identity,
            authIdentityStore: store,
            isAuthFeatureEnabled: { true }
        )
        let disabled = DefaultAuthLinkingReadinessUseCase(
            identityRepository: identity,
            authIdentityStore: store,
            isAuthFeatureEnabled: { false }
        )

        XCTAssertTrue(enabled.snapshot().canStartLinking)
        XCTAssertFalse(disabled.snapshot().canStartLinking)
    }

    func testSettingsPreferencesUseCaseUpdatesOptInState() {
        let repository = FakeCloudBackupSettingsRepository(isOptedIn: false)
        let useCase = DefaultSettingsPreferencesUseCase(
            settingsRepository: repository,
            featureFlags: {
                FeatureFlags(
                    isCloudBackupEnabled: true,
                    isRestoreEnabled: false,
                    isAuthEnabled: false,
                    isDevelopmentUploadEnabled: false
                )
            }
        )

        XCTAssertFalse(useCase.loadPreferences().isCloudBackupOptedIn)

        useCase.setCloudBackupOptIn(true)

        XCTAssertTrue(useCase.loadPreferences().isCloudBackupOptedIn)
        XCTAssertTrue(useCase.loadPreferences().featureFlags.isCloudBackupEnabled)
    }

    func testRecordingLifecycleUseCaseDelegatesToPurePolicy() {
        let useCase = DefaultRecordingLifecycleUseCase()

        XCTAssertEqual(try? useCase.transition(from: .idle, event: .start).get(), .recording)
        XCTAssertEqual(useCase.transition(from: .paused, event: .ingestPoint), .failure(.cannotIngestPoint))
    }
}

private final class FakeDaySummaryRepository: DaySummaryRepository {
    private let distanceToday: Double
    private let distanceTotal: Double
    private let monthlyDistance: Double

    init(distanceToday: Double, distanceTotal: Double, monthlyDistance: Double) {
        self.distanceToday = distanceToday
        self.distanceTotal = distanceTotal
        self.monthlyDistance = monthlyDistance
    }

    func loadDistance(total: Bool) -> Double {
        total ? distanceTotal : distanceToday
    }

    func loadMonthlyDistance() -> Double {
        monthlyDistance
    }

    func saveTotalDistance(value: Double) throws {}

    func makeTodaySummaryDraft(installationId: InstallationID) -> DaySummaryDraft {
        DaySummaryDraft(
            localDate: "2026-07-05",
            ownerId: nil,
            deviceId: nil,
            distanceMeters: distanceToday,
            recordingCount: 0,
            pointCount: 0,
            previewAssetId: nil,
            syncStatus: .localOnly
        )
    }
}

private final class FakeWidgetStateStore: WidgetStateStore {
    var isTracking: Bool
    var distanceToday: Double
    var distanceTotal: Double
    var selectedColor: String?

    init(isTracking: Bool, distanceToday: Double, distanceTotal: Double, selectedColor: String?) {
        self.isTracking = isTracking
        self.distanceToday = distanceToday
        self.distanceTotal = distanceTotal
        self.selectedColor = selectedColor
    }
}

private final class FakeColorRepository: ColorRepository {
    private let ranking: [(key: String, value: Double)]

    init(ranking: [(key: String, value: Double)]) {
        self.ranking = ranking
    }

    func update(hex: String, distance: Double) throws {}
    func distance(hex: String, startDate: Int, endDate: Int) -> Double { 0 }
    func rankingDistance(startDate: Int, endDate: Int) -> [(key: String, value: Double)] { ranking }
    func footsteps(hex: String, from startDate: Int, to endDate: Int) -> [List<Footstep>] { [] }
}

private final class FakePlaceRepository: PlaceRepository {
    private let ranking: [(key: String, value: Double)]

    init(ranking: [(key: String, value: Double)]) {
        self.ranking = ranking
    }

    func update(latitude: Double, longitude: Double, distance: Double) {}
    func distance(value: String, startDate: Int, endDate: Int) -> Double { 0 }
    func rankingDistance(startDate: Int, endDate: Int) -> [(key: String, value: Double)] { ranking }
}

private final class FakeManualCloudBackupRunner: ManualCloudBackupRunning {
    private let result: ManualBackupPreparationResult

    init(result: ManualBackupPreparationResult) {
        self.result = result
    }

    func prepareLocalRouteBackup(configuration: SyncBatchConfiguration) throws -> ManualBackupPreparationResult {
        result
    }

    func localBackupStatus() -> LocalBackupStatus {
        result.localBackupStatus
    }
}

private final class FakeDeviceIdentityRepository: DeviceIdentityRepository {
    private let storedOwnerId: OwnerID?

    init(ownerId: OwnerID?) {
        self.storedOwnerId = ownerId
    }

    func installationId() -> InstallationID {
        InstallationID(rawValue: "inst_1")
    }

    func ownerId() -> OwnerID? {
        storedOwnerId
    }

    func deviceId() -> DeviceID? {
        DeviceID(rawValue: "dev_1")
    }

    func save(ownerId: OwnerID?, deviceId: DeviceID?) {}
}

private final class FakeAuthIdentityStore: AuthIdentityStore {
    private var storedState: AuthLinkState

    init(state: AuthLinkState) {
        self.storedState = state
    }

    func currentIdentity() -> AuthIdentity? { nil }
    func save(_ identity: AuthIdentity) {}
    func state() -> AuthLinkState { storedState }
    func saveState(_ state: AuthLinkState) { storedState = state }
}

private final class FakeCloudBackupSettingsRepository: CloudBackupSettingsRepository {
    var isOptedIn: Bool

    init(isOptedIn: Bool) {
        self.isOptedIn = isOptedIn
    }
}
