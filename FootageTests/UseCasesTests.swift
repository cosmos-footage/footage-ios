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
                    isDevelopmentUploadEnabled: false,
                    isNewUIRunwayEnabled: false
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

    func testAppRootRouterKeepsLegacyStoryboardDefault() {
        let router = AppRootRouter(featureFlags: .disabled)

        XCTAssertEqual(router.route(userState: nil), .legacyFirstLaunch)
        XCTAssertEqual(router.route(userState: "noPassword"), .legacyMainTabs)
        XCTAssertTrue(router.route(userState: "noPassword").usesStoryboard)
    }

    func testAppRootRouterCanSelectRenewedShellBehindFlagWithoutSkippingFirstLaunch() {
        let router = AppRootRouter(
            featureFlags: FeatureFlags(isNewUIRunwayEnabled: true)
        )

        XCTAssertEqual(router.route(userState: nil), .legacyFirstLaunch)
        XCTAssertEqual(router.route(userState: "noPassword"), .renewedUIKitShell)
        XCTAssertFalse(router.route(userState: "noPassword").usesStoryboard)
    }

    func testAppRootViewControllerFactoryBuildsRouteRootsWithoutRuntimeCutover() throws {
        let mainTabs = UITabBarController()
        let firstLaunch = UIViewController()
        let renewedRoot = UIViewController()
        let factory = AppRootViewControllerFactory(
            legacyRootFactory: FakeLegacyRootViewControllerFactory(
                mainTabs: mainTabs,
                firstLaunch: firstLaunch
            ),
            renewedShellRootFactory: { renewedRoot }
        )

        XCTAssertTrue(try XCTUnwrap(factory.makeRootViewController(for: .legacyMainTabs)) === mainTabs)
        XCTAssertTrue(try XCTUnwrap(factory.makeRootViewController(for: .legacyFirstLaunch)) === firstLaunch)
        XCTAssertTrue(try XCTUnwrap(factory.makeRootViewController(for: .renewedUIKitShell)) === renewedRoot)
    }

    func testAppCompositionRootBuildsAppRootRoutingBoundaries() throws {
        let compositionRoot = AppCompositionRoot(
            environment: AppEnvironment(
                featureFlags: FeatureFlags(isNewUIRunwayEnabled: true)
            )
        )
        let mainTabs = UITabBarController()
        let firstLaunch = UIViewController()
        let factory = compositionRoot.makeAppRootViewControllerFactory(
            legacyRootFactory: FakeLegacyRootViewControllerFactory(
                mainTabs: mainTabs,
                firstLaunch: firstLaunch
            )
        )

        XCTAssertEqual(compositionRoot.makeAppRootRouter().route(userState: "noPassword"), .renewedUIKitShell)
        XCTAssertTrue(try XCTUnwrap(factory.makeRootViewController(for: .legacyMainTabs)) === mainTabs)
        XCTAssertTrue(try XCTUnwrap(factory.makeRootViewController(for: .legacyFirstLaunch)) === firstLaunch)
    }

    func testAppLaunchConfigurationStillUsesMainStoryboardDuringRenewedShellRunway() throws {
        let info = try XCTUnwrap(Bundle(for: AppDelegate.self).infoDictionary)

        XCTAssertEqual(info["UIMainStoryboardFile"] as? String, "Main")

        let sceneManifest = try XCTUnwrap(info["UIApplicationSceneManifest"] as? [String: Any])
        let sceneConfigurations = try XCTUnwrap(sceneManifest["UISceneConfigurations"] as? [String: Any])
        let applicationScenes = try XCTUnwrap(
            sceneConfigurations["UIWindowSceneSessionRoleApplication"] as? [[String: Any]]
        )
        let defaultScene = try XCTUnwrap(applicationScenes.first)

        XCTAssertEqual(defaultScene["UISceneStoryboardFile"] as? String, "Main")
    }

    func testSceneLifecycleCoordinatorPlansForegroundPasswordGate() {
        let coordinator = SceneLifecycleCoordinator()

        XCTAssertEqual(
            coordinator.foregroundPlan(userState: "hasPassword", alwaysOn: true),
            SceneForegroundPlan(shouldInvalidateAlwaysOnTimer: true, route: .passwordUnlock)
        )
        XCTAssertEqual(
            coordinator.foregroundPlan(userState: "hasBioId", alwaysOn: false),
            SceneForegroundPlan(shouldInvalidateAlwaysOnTimer: false, route: .passwordUnlock)
        )
    }

    func testSceneLifecycleCoordinatorPlansFirstLaunchAndDefaultForeground() {
        let coordinator = SceneLifecycleCoordinator()

        XCTAssertEqual(
            coordinator.foregroundPlan(userState: nil, alwaysOn: true),
            SceneForegroundPlan(shouldInvalidateAlwaysOnTimer: true, route: .firstLaunch)
        )
        XCTAssertEqual(
            coordinator.foregroundPlan(userState: "noPassword", alwaysOn: true),
            SceneForegroundPlan(shouldInvalidateAlwaysOnTimer: true, route: .none)
        )
    }

    func testSceneLifecycleCoordinatorPlansInitialConnection() {
        let coordinator = SceneLifecycleCoordinator()

        XCTAssertEqual(
            coordinator.initialConnectionPlan(isWindowScene: false, url: URL(string: "widget://toggle")),
            SceneInitialConnectionPlan(
                shouldPrepareLegacyHome: false,
                shouldStartTrackingFromWidget: false
            )
        )
        XCTAssertEqual(
            coordinator.initialConnectionPlan(isWindowScene: true, url: URL(string: "widget://toggle")),
            SceneInitialConnectionPlan(
                shouldPrepareLegacyHome: true,
                shouldStartTrackingFromWidget: true
            )
        )
        XCTAssertEqual(
            coordinator.initialConnectionPlan(isWindowScene: true, url: URL(string: "footage://toggle")),
            SceneInitialConnectionPlan(
                shouldPrepareLegacyHome: true,
                shouldStartTrackingFromWidget: false
            )
        )
    }

    func testSceneLifecycleCoordinatorPlansAppRootInstallAction() {
        let coordinator = SceneLifecycleCoordinator()

        XCTAssertEqual(coordinator.appRootInstallAction(route: .legacyFirstLaunch), .keepStoryboardRoot)
        XCTAssertEqual(coordinator.appRootInstallAction(route: .legacyMainTabs), .keepStoryboardRoot)
        XCTAssertEqual(
            coordinator.appRootInstallAction(route: .renewedUIKitShell),
            .replaceRoot(.renewedUIKitShell)
        )
    }

    func testSceneLifecycleCoordinatorHandlesWidgetURLsAndTrackingActions() {
        let coordinator = SceneLifecycleCoordinator()

        XCTAssertTrue(coordinator.isWidgetURL(URL(string: "widget://toggle")))
        XCTAssertFalse(coordinator.isWidgetURL(URL(string: "footage://toggle")))
        XCTAssertFalse(coordinator.isWidgetURL(nil))
        XCTAssertEqual(coordinator.widgetTrackingAction(wasTracking: false), .start)
        XCTAssertEqual(coordinator.widgetTrackingAction(wasTracking: true), .stop)
        XCTAssertEqual(coordinator.homeTrackingCommand(for: .start), .start)
        XCTAssertEqual(coordinator.homeTrackingCommand(for: .stop), .stop)
        XCTAssertEqual(coordinator.initialHomeTrackingCommand(shouldStartFromWidget: true), .start)
        XCTAssertNil(coordinator.initialHomeTrackingCommand(shouldStartFromWidget: false))
    }

    func testSceneLifecycleCoordinatorPlansBackgroundRecordingAction() {
        let coordinator = SceneLifecycleCoordinator()

        XCTAssertEqual(
            coordinator.backgroundRecordingAction(isRecording: false, alwaysOn: true),
            .none
        )
        XCTAssertEqual(
            coordinator.backgroundRecordingAction(isRecording: true, alwaysOn: true),
            .scheduleAlwaysOnLocationRefresh
        )
        XCTAssertEqual(
            coordinator.backgroundRecordingAction(isRecording: true, alwaysOn: false),
            .startUpdatingLocation
        )
    }

    func testFirstLaunchDefaultsInitializerPreservesLegacyDefaultKeys() {
        let standardDefaults = makeIsolatedDefaults(name: "first-launch-standard")
        let widgetDefaults = makeIsolatedDefaults(name: "first-launch-widget")
        let initializer = FirstLaunchDefaultsInitializer(
            standardDefaults: standardDefaults,
            widgetDefaults: widgetDefaults
        )

        initializer.apply()

        XCTAssertEqual(standardDefaults.string(forKey: "todayBadge"), "")
        XCTAssertEqual(standardDefaults.integer(forKey: "minimumTotalDistance"), 0)
        XCTAssertEqual(standardDefaults.integer(forKey: "minimumTotalRecord"), 0)
        XCTAssertFalse(standardDefaults.bool(forKey: "startedBefore"))
        XCTAssertEqual(widgetDefaults.string(forKey: "#EADE4Cff"), "노란색")
        XCTAssertEqual(widgetDefaults.string(forKey: "#F5A997ff"), "분홍색")
        XCTAssertEqual(widgetDefaults.string(forKey: "#F0E7CFff"), "흰  색")
        XCTAssertEqual(widgetDefaults.string(forKey: "#FF6B39ff"), "주황색")
        XCTAssertEqual(widgetDefaults.string(forKey: "#206491ff"), "파란색")
    }

    func testSceneWidgetTrackingStateStoreTogglesAndClearsLegacyTrackingKey() {
        let defaults = makeIsolatedDefaults(name: "widget-tracking")
        let store = SceneWidgetTrackingStateStore(defaults: defaults)

        XCTAssertEqual(store.toggleTracking(), false)
        XCTAssertTrue(defaults.bool(forKey: "isTracking"))
        XCTAssertEqual(store.toggleTracking(), true)
        XCTAssertFalse(defaults.bool(forKey: "isTracking"))

        defaults.set(true, forKey: "isTracking")
        store.clearTracking()

        XCTAssertFalse(defaults.bool(forKey: "isTracking"))
    }

    func testSceneUserStateStoreReadsLegacyForegroundKeys() {
        let defaults = makeIsolatedDefaults(name: "scene-user-state")
        let store = SceneUserStateStore(defaults: defaults)

        defaults.set("hasPassword", forKey: "UserState")
        defaults.set(true, forKey: "alwaysOn")

        XCTAssertEqual(store.userState(), "hasPassword")
        XCTAssertTrue(store.isAlwaysOnEnabled())
    }

    func testLegacyHomeTabControllerAccessorSelectsFirstTab() {
        let homeViewController = UIViewController()
        let otherViewController = UIViewController()
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeViewController, otherViewController]
        tabBarController.selectedIndex = 1
        let accessor = LegacyHomeTabControllerAccessor()

        let selectedHome = accessor.selectHomeTab(from: tabBarController)

        XCTAssertTrue(selectedHome === homeViewController)
        XCTAssertEqual(tabBarController.selectedIndex, 0)
    }

    func testLegacyHomeTabControllerAccessorReturnsNilForNonHomeRoot() {
        let accessor = LegacyHomeTabControllerAccessor()

        XCTAssertNil(accessor.selectHomeTab(from: UIViewController()))
        XCTAssertNil(accessor.selectHomeTab(from: nil))
    }

    func testSceneFullScreenPresenterFindsPresentedTopController() {
        let presented = FakePresentedViewController()
        let root = FakePresentedViewController(presentedViewControllerOverride: presented)
        let presenter = SceneFullScreenPresenter()

        XCTAssertTrue(presenter.topViewController(from: root) === presented)
    }

    func testSceneFullScreenPresenterPreparesLegacyFullScreenSizing() {
        let viewController = UIViewController()
        let presenter = SceneFullScreenPresenter()

        presenter.prepareFullScreen(
            viewController,
            screenBounds: CGRect(x: 0, y: 0, width: 320, height: 640)
        )

        XCTAssertFalse(viewController.view.translatesAutoresizingMaskIntoConstraints)
        XCTAssertEqual(viewController.modalPresentationStyle, .fullScreen)
        XCTAssertTrue(
            viewController.view.constraints.contains {
                $0.firstAttribute == .width && $0.constant == 320 && $0.isActive
            }
        )
        XCTAssertTrue(
            viewController.view.constraints.contains {
                $0.firstAttribute == .height && $0.constant == 640 && $0.isActive
            }
        )
    }

    func testSceneRootControllerInstallerReplacesWindowRoot() {
        let window = UIWindow(frame: .zero)
        let rootViewController = UIViewController()
        let installer = SceneRootControllerInstaller()

        installer.installRoot(rootViewController, in: window)

        XCTAssertTrue(window.rootViewController === rootViewController)
    }

    func testSceneSelectedColorStoreReadsLegacyAppGroupKey() {
        let defaults = makeIsolatedDefaults(name: "selected-color")
        let store = SceneSelectedColorStore(defaults: defaults)

        defaults.set("#EADE4Cff", forKey: "selectedColor")

        XCTAssertEqual(store.selectedColor(), "#EADE4Cff")
    }

    func testSceneHomeInitialDataLoadingBoundaryCanBeFaked() {
        let loader = FakeSceneHomeInitialDataLoader()

        loader.prepareLegacyHomeData()

        XCTAssertTrue(loader.didPrepareLegacyHomeData)
    }

    func testSceneHomeViewControllerDispatcherBoundaryCanBeFaked() {
        let dispatcher = FakeSceneHomeViewControllerDispatcher()
        let viewController = UIViewController()

        dispatcher.restoreSelectedCategory("#EADE4Cff", on: viewController)
        dispatcher.dispatchTrackingCommand(.start, to: viewController)
        dispatcher.dispatchTrackingCommand(.stop, to: viewController)

        XCTAssertEqual(dispatcher.restoredSelectedColor, "#EADE4Cff")
        XCTAssertEqual(dispatcher.trackingCommands, [.start, .stop])
        XCTAssertTrue(dispatcher.lastViewController === viewController)
    }

    func testSceneBackgroundRecordingDispatcherBoundaryCanBeFaked() {
        let dispatcher = FakeSceneBackgroundRecordingDispatcher()
        var assignedTimer: Timer?

        dispatcher.dispatch(.scheduleAlwaysOnLocationRefresh) { timer in
            assignedTimer = timer
        }
        dispatcher.dispatch(.startUpdatingLocation) { _ in }

        XCTAssertEqual(
            dispatcher.dispatchedActions,
            [.scheduleAlwaysOnLocationRefresh, .startUpdatingLocation]
        )
        XCTAssertNotNil(assignedTimer)
    }

    func testSceneForegroundRouteDispatcherBoundaryCanBeFaked() {
        let dispatcher = FakeSceneForegroundRouteDispatcher()
        let plan = SceneForegroundPlan(
            shouldInvalidateAlwaysOnTimer: true,
            route: .passwordUnlock
        )
        var didInvalidateTimer = false

        dispatcher.dispatch(plan, in: UIWindow(frame: .zero)) {
            didInvalidateTimer = true
        }

        XCTAssertEqual(dispatcher.dispatchedPlans, [plan])
        XCTAssertTrue(didInvalidateTimer)
    }

    func testSceneWidgetTimelineReloaderBoundaryCanBeFaked() {
        let reloader = FakeSceneWidgetTimelineReloader()

        reloader.reloadAllTimelines()
        reloader.reloadAllTimelines()

        XCTAssertEqual(reloader.reloadCount, 2)
    }
}

private final class FakeSceneHomeInitialDataLoader: SceneHomeInitialDataLoading {
    private(set) var didPrepareLegacyHomeData = false

    func prepareLegacyHomeData() {
        didPrepareLegacyHomeData = true
    }
}

private final class FakeSceneHomeViewControllerDispatcher: SceneHomeViewControllerDispatching {
    private(set) var restoredSelectedColor: String?
    private(set) var trackingCommands: [SceneHomeTrackingCommand] = []
    private(set) weak var lastViewController: UIViewController?

    func restoreSelectedCategory(_ selectedColor: String?, on viewController: UIViewController?) {
        restoredSelectedColor = selectedColor
        lastViewController = viewController
    }

    func dispatchTrackingCommand(_ command: SceneHomeTrackingCommand, to viewController: UIViewController?) {
        trackingCommands.append(command)
        lastViewController = viewController
    }
}

private final class FakeSceneBackgroundRecordingDispatcher: SceneBackgroundRecordingDispatching {
    private(set) var dispatchedActions: [SceneBackgroundRecordingAction] = []

    func dispatch(
        _ action: SceneBackgroundRecordingAction,
        timerAssignment: @escaping (Timer) -> Void
    ) {
        dispatchedActions.append(action)

        if action == .scheduleAlwaysOnLocationRefresh {
            let timer = Timer(timeInterval: 2.5, repeats: true) { _ in }
            timerAssignment(timer)
        }
    }
}

private final class FakeSceneForegroundRouteDispatcher: SceneForegroundRouteDispatching {
    private(set) var dispatchedPlans: [SceneForegroundPlan] = []

    func dispatch(
        _ plan: SceneForegroundPlan,
        in window: UIWindow?,
        timerInvalidation: () -> Void
    ) {
        dispatchedPlans.append(plan)

        if plan.shouldInvalidateAlwaysOnTimer {
            timerInvalidation()
        }
    }
}

private final class FakeSceneWidgetTimelineReloader: SceneWidgetTimelineReloading {
    private(set) var reloadCount = 0

    func reloadAllTimelines() {
        reloadCount += 1
    }
}

private final class FakePresentedViewController: UIViewController {
    private let presentedViewControllerOverride: UIViewController?

    init(presentedViewControllerOverride: UIViewController? = nil) {
        self.presentedViewControllerOverride = presentedViewControllerOverride
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var presentedViewController: UIViewController? {
        presentedViewControllerOverride
    }
}

private struct FakeLegacyRootViewControllerFactory: LegacyRootViewControllerFactory {
    let mainTabs: UITabBarController?
    let firstLaunch: UIViewController

    func makeMainTabs() -> UITabBarController? {
        mainTabs
    }

    func makeFirstLaunch() -> UIViewController {
        firstLaunch
    }

    func makePasswordUnlock() -> PasswordVC? {
        nil
    }
}

private func makeIsolatedDefaults(name: String) -> UserDefaults {
    let suiteName = "FootageTests.\(name).\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suiteName)!
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
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
