//
//  PresentationModelsTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/05.
//

import UIKit
import XCTest
@testable import footage

final class PresentationModelsTests: XCTestCase {
    func testJourneyDatePresentationFormatsYearMonthAndDayKeys() {
        XCTAssertEqual(JourneyDatePresentation(legacyDateKey: 2026).title, "2026년")
        XCTAssertEqual(JourneyDatePresentation(legacyDateKey: 202607).title, "2026년 7월")
        XCTAssertEqual(JourneyDatePresentation(legacyDateKey: 20260705).title, "7월 5일")
    }

    func testJourneyDatePresentationExposesGranularity() {
        XCTAssertEqual(JourneyDatePresentation(legacyDateKey: 2026).granularity, .year)
        XCTAssertEqual(JourneyDatePresentation(legacyDateKey: 202607).granularity, .month)
        XCTAssertEqual(JourneyDatePresentation(legacyDateKey: 20260705).granularity, .day)
    }

    func testJourneyTimelineItemPresentationKeepsPreviewData() {
        let previewData = Data([0x01, 0x02, 0x03])
        let item = JourneyTimelineItemPresentation(
            legacyDateKey: 20260705,
            previewData: previewData
        )

        XCTAssertEqual(item.legacyDateKey, 20260705)
        XCTAssertEqual(item.title, "7월 5일")
        XCTAssertEqual(item.previewData, previewData)
    }

    func testJourneyDateDetailPresentationForYearJourney() {
        let presentation = JourneyDateDetailPresentation(legacyDateKey: 2026)

        XCTAssertEqual(presentation.granularity, .year)
        XCTAssertTrue(presentation.shouldHideMonth)
        XCTAssertTrue(presentation.shouldHideDay)
        XCTAssertEqual(presentation.yearCounterStart, 2000)
        XCTAssertEqual(presentation.yearCounterEnd, 2026)
        XCTAssertNil(presentation.monthCounterEnd)
        XCTAssertNil(presentation.dayCounterEnd)
    }

    func testJourneyDateDetailPresentationForMonthJourney() {
        let presentation = JourneyDateDetailPresentation(legacyDateKey: 202607)

        XCTAssertEqual(presentation.granularity, .month)
        XCTAssertFalse(presentation.shouldHideMonth)
        XCTAssertTrue(presentation.shouldHideDay)
        XCTAssertEqual(presentation.yearCounterStart, 2000)
        XCTAssertEqual(presentation.yearCounterEnd, 2026)
        XCTAssertEqual(presentation.monthCounterEnd, 7)
        XCTAssertNil(presentation.dayCounterEnd)
        XCTAssertTrue(presentation.shouldPadMonth)
    }

    func testJourneyDateDetailPresentationForDayJourneyPreservesLegacyTwoDigitYearCounter() {
        let presentation = JourneyDateDetailPresentation(legacyDateKey: 20260705)

        XCTAssertEqual(presentation.granularity, .day)
        XCTAssertFalse(presentation.shouldHideMonth)
        XCTAssertFalse(presentation.shouldHideDay)
        XCTAssertEqual(presentation.yearCounterStart, 0)
        XCTAssertEqual(presentation.yearCounterEnd, 26)
        XCTAssertEqual(presentation.monthCounterEnd, 7)
        XCTAssertEqual(presentation.dayCounterEnd, 5)
        XCTAssertTrue(presentation.shouldPadMonth)
        XCTAssertTrue(presentation.shouldPadDay)
    }

    func testHomeDistancePresentationForRecordingToday() {
        let presentation = HomeDistancePresentation(
            mode: .recordingToday,
            distanceMeters: 1234
        )

        XCTAssertEqual(presentation.todayText, "오늘")
        XCTAssertEqual(presentation.youText, "당신이 새로 남긴")
        XCTAssertEqual(presentation.footText, "발자취")
        XCTAssertEqual(presentation.counterValueKilometers, 1.234)
        XCTAssertEqual(presentation.formattedSourceValue, "1.23")
        XCTAssertEqual(presentation.formattedCounterValue(0), "0.00")
    }

    func testHomeDistancePresentationForTotalArchive() {
        let presentation = HomeDistancePresentation(
            mode: .totalArchive,
            distanceMeters: 1234
        )

        XCTAssertEqual(presentation.todayText, "오늘까지")
        XCTAssertEqual(presentation.youText, "당신이 남긴")
        XCTAssertEqual(presentation.footText, "발자취")
        XCTAssertEqual(presentation.counterValueKilometers, 1.234)
        XCTAssertEqual(presentation.formattedSourceValue, "1")
        XCTAssertEqual(presentation.formattedCounterValue(1.6), "2")
    }

    func testCityPresentationMapsKnownKoreanAndEnglishNames() {
        XCTAssertEqual(
            CityPresentation(sourceName: "서울특별시", fallback: .noData).imageName,
            "Seoul"
        )
        XCTAssertEqual(
            CityPresentation(sourceName: "Seoul", fallback: .noData).nicknameText,
            "\"서울특별시\""
        )
        XCTAssertEqual(
            CityPresentation(sourceName: "North Gyeongsang", fallback: .noData).imageName,
            "North Gyeongsang"
        )
    }

    func testCityPresentationUsesContextualFallbacks() {
        XCTAssertEqual(
            CityPresentation(sourceName: "Unknown", fallback: .sejong).imageName,
            "Sejong City"
        )
        XCTAssertEqual(
            CityPresentation(sourceName: "Unknown", fallback: .sejong).nicknameText,
            "\"세종특별자치시\""
        )
        XCTAssertEqual(
            CityPresentation(sourceName: "Unknown", fallback: .noData).imageName,
            "noDataImage"
        )
        XCTAssertEqual(
            CityPresentation(sourceName: "Unknown", fallback: .noData).nicknameText,
            "-"
        )
    }

    func testDistanceTextPresentationFormatsLegacyStatsDistances() {
        XCTAssertEqual(
            DistanceTextPresentation(meters: 1234, style: .integer).text,
            "1"
        )
        XCTAssertEqual(
            DistanceTextPresentation(meters: 1234, style: .decimal2).text,
            "1.23"
        )
        XCTAssertEqual(
            DistanceTextPresentation(meters: 1234, style: .integerWithKm).text,
            "1km"
        )
        XCTAssertEqual(
            DistanceTextPresentation(meters: 1234, style: .decimal2WithKm).text,
            "1.23km"
        )
    }

    func testReportButtonPresentationUsesLegacyEnabledAlphaPairing() {
        XCTAssertTrue(ReportButtonPresentation(hasData: true).isEnabled)
        XCTAssertEqual(ReportButtonPresentation(hasData: true).alpha, 1)
        XCTAssertFalse(ReportButtonPresentation(hasData: false).isEnabled)
        XCTAssertEqual(ReportButtonPresentation(hasData: false).alpha, 0.1)
    }

    func testMapFootstepPresentationFormatsLegacyCellText() {
        let presentation = MapFootstepPresentation(
            legacyDateKey: 20260705,
            distanceKilometers: 1.234,
            categoryName: "산책",
            photoCount: 2,
            noteCount: 1
        )

        XCTAssertEqual(presentation.dateText, "2026년 7월 5일")
        XCTAssertEqual(presentation.distanceText, "1.23km")
        XCTAssertEqual(presentation.categoryName, "산책")
        XCTAssertEqual(presentation.photoCountText, "사진: 2")
        XCTAssertEqual(presentation.noteCountText, "글: 1")
    }

    func testCloudBackupStatusPresentationFormatsPendingAndFailedCounts() {
        let presentation = CloudBackupStatusPresentation(
            pendingCount: 3,
            failedCount: 1
        )

        XCTAssertEqual(presentation.text, "대기 3 / 실패 1")
    }

    func testSettingsPushTimePresentationKeepsLegacyRowFormatting() {
        let presentation = SettingsPushTimePresentation(hour: 8, minute: 5)

        XCTAssertEqual(presentation.rowText, "8시 5분")
        XCTAssertEqual(presentation.settingsRowText(title: "일일 알림 시간"), "일일 알림 시간 :    8시 5분")
        XCTAssertEqual(SettingsPushTimePresentation.pickerRowText(5), "05")
        XCTAssertEqual(SettingsPushTimePresentation.pickerRowText(12), "12")
    }

    func testSettingsPreferencesPresentationFormatsReadOnlyFeatureState() {
        let presentation = SettingsPreferencesPresentation(
            snapshot: SettingsPreferencesSnapshot(
                isCloudBackupOptedIn: true,
                featureFlags: FeatureFlags(
                    isCloudBackupEnabled: true,
                    isRestoreEnabled: false,
                    isAuthEnabled: true,
                    isDevelopmentUploadEnabled: false,
                    isNewUIRunwayEnabled: true
                )
            )
        )

        XCTAssertEqual(presentation.backupOptInText, "백업 사용 중")
        XCTAssertEqual(presentation.backupFeatureText, "백업 기능 준비됨")
        XCTAssertEqual(presentation.restoreFeatureText, "복원 기능 비활성")
        XCTAssertEqual(presentation.authFeatureText, "계정 연결 준비됨")
    }

    func testAppVersionPresentationFormatsLegacyVersionCode() {
        XCTAssertEqual(
            AppVersionPresentation(legacyVersionCode: 122).text,
            "버전정보 v1.2.2"
        )
    }

    func testRestoreStatusPresentationMapsStatusTextAndProgressState() {
        XCTAssertEqual(RestoreStatusPresentation(status: .idle).title, "복원 대기")
        XCTAssertFalse(RestoreStatusPresentation(status: .idle).isInProgress)
        XCTAssertEqual(RestoreStatusPresentation(status: .downloading).title, "복원 데이터 다운로드 중")
        XCTAssertTrue(RestoreStatusPresentation(status: .downloading).isInProgress)
        XCTAssertEqual(RestoreStatusPresentation(status: .failed).title, "복원 실패")
        XCTAssertFalse(RestoreStatusPresentation(status: .failed).isInProgress)
    }

    func testRestoreImportPlanPresentationFormatsCountsAndGuards() {
        let plan = RestoreImportPlan(
            ownerId: OwnerID(rawValue: "own_1"),
            sourceDeviceId: DeviceID(rawValue: "dev_1"),
            recordingCount: 2,
            routePointCount: 25,
            duplicateCandidateCount: 3,
            estimatedImportSizeBytes: 1024,
            canImport: true,
            requiresUserConfirmation: true,
            conflictPolicy: .skipExisting
        )
        let presentation = RestoreImportPlanPresentation(plan: plan)

        XCTAssertEqual(presentation.recordingCountText, "기록 2개")
        XCTAssertEqual(presentation.routePointCountText, "경로점 25개")
        XCTAssertEqual(presentation.duplicateCandidateCountText, "중복 후보 3개")
        XCTAssertEqual(presentation.estimatedImportSizeText, "예상 크기 1024B")
        XCTAssertTrue(presentation.canImport)
        XCTAssertTrue(presentation.requiresUserConfirmation)
    }

    func testAuthLinkingReadinessPresentationUsesSnapshotGate() {
        let readySnapshot = AuthLinkingReadinessSnapshot(
            ownerId: OwnerID(rawValue: "own_1"),
            authLinkState: .anonymous,
            isAuthFeatureEnabled: true
        )
        let ready = AuthLinkingReadinessPresentation(snapshot: readySnapshot)

        XCTAssertEqual(ready.title, "익명 백업 사용 중")
        XCTAssertTrue(ready.isActionEnabled)
        XCTAssertEqual(ready.actionTitle, "계정 연결")

        let linkingSnapshot = AuthLinkingReadinessSnapshot(
            ownerId: OwnerID(rawValue: "own_1"),
            authLinkState: .linking,
            isAuthFeatureEnabled: true
        )
        let linking = AuthLinkingReadinessPresentation(snapshot: linkingSnapshot)

        XCTAssertEqual(linking.title, "계정 연결 중")
        XCTAssertFalse(linking.isActionEnabled)
        XCTAssertNil(linking.actionTitle)
    }

    func testBadgePresentationFormatsDetailTextWithoutRealmDependency() {
        let presentation = BadgePresentation(
            imageName: "total_5",
            detail: "지금까지 남긴 발자취가 5km가 넘었어요!"
        )

        XCTAssertEqual(presentation.imageName, "total_5")
        XCTAssertEqual(presentation.detailText, "\"지금까지 남긴 발자취가 5km가 넘었어요!\"")
        XCTAssertEqual(BadgePresentation(imageName: "", detail: "").detailText, "")
    }

    func testRenewedShellPresentationDefinesDefaultInternalTabs() {
        let presentation = RenewedShellPresentation.default

        XCTAssertEqual(presentation.tabs.map(\.kind), [.today, .map, .timeline, .stats, .settings])
        XCTAssertEqual(presentation.tabs.map(\.title), ["오늘", "지도", "기록", "통계", "설정"])
        XCTAssertEqual(presentation.tabs.map(\.systemImageName), ["figure.walk", "map", "calendar", "chart.bar", "gearshape"])
    }

    func testRenewedShellPresentationDefinesLegacyStoryboardBridgeOrder() {
        let presentation = RenewedShellPresentation.legacyStoryboardBridge

        XCTAssertEqual(presentation.tabs.map(\.kind), [.today, .map, .stats, .timeline, .settings])
        XCTAssertEqual(presentation.tabs.map(\.title), ["홈", "지도", "월간 리포트", "기록", "설정"])
        XCTAssertEqual(
            presentation.tabs.map(\.systemImageName),
            ["house.fill", "location.fill", "rectangle.grid.1x2.fill", "person.fill", "circle.grid.2x2.fill"]
        )
    }

    func testPlaceholderRenewedShellFactoryBuildsTabSpecificPlaceholderController() {
        let tab = RenewedShellTab(kind: .stats, title: "통계", systemImageName: "chart.bar")
        let controller = PlaceholderRenewedShellViewControllerFactory().makeViewController(for: tab)

        let placeholder = controller as? RenewedShellPlaceholderViewController
        XCTAssertEqual(placeholder?.shellTab, tab)
        XCTAssertEqual(placeholder?.title, "통계")
    }

    func testProgrammaticRenewedShellFactoryUsesPlaceholderScreensForDefaultTabs() {
        let factory = ProgrammaticRenewedShellViewControllerFactory()

        let controllers = RenewedShellPresentation.default.tabs.map {
            factory.makeViewController(for: $0)
        }

        XCTAssertEqual(controllers.count, RenewedShellPresentation.default.tabs.count)
        XCTAssertEqual(
            controllers.compactMap { ($0 as? RenewedShellPlaceholderViewController)?.shellTab },
            RenewedShellPresentation.default.tabs
        )
    }

    func testProgrammaticRenewedShellFactoryBuildsTodayDashboardWhenUseCaseExists() {
        let factory = ProgrammaticRenewedShellViewControllerFactory(
            homeDashboardUseCase: {
                FakeHomeDashboardUseCase(
                    snapshot: HomeDashboardSnapshot(
                        distanceTodayMeters: 1_230,
                        distanceTotalMeters: 10_000,
                        isTracking: true,
                        selectedColorCategoryId: nil,
                        generatedAt: Date(timeIntervalSince1970: 100)
                    )
                )
            }
        )

        let today = factory.makeViewController(
            for: RenewedShellTab(kind: .today, title: "오늘", systemImageName: "figure.walk")
        )
        let settings = factory.makeViewController(
            for: RenewedShellTab(kind: .settings, title: "설정", systemImageName: "gearshape")
        )

        XCTAssertTrue(today is RenewedTodayDashboardViewController)
        XCTAssertTrue(settings is RenewedShellPlaceholderViewController)
    }

    func testProgrammaticRenewedShellFactoryBuildsSettingsDashboardWhenUseCaseExists() {
        let factory = ProgrammaticRenewedShellViewControllerFactory(
            settingsPreferencesUseCase: {
                FakeSettingsPreferencesUseCase(
                    snapshot: SettingsPreferencesSnapshot(
                        isCloudBackupOptedIn: false,
                        featureFlags: FeatureFlags(
                            isCloudBackupEnabled: false,
                            isRestoreEnabled: false,
                            isAuthEnabled: false,
                            isDevelopmentUploadEnabled: false,
                            isNewUIRunwayEnabled: true
                        )
                    )
                )
            }
        )

        let settings = factory.makeViewController(
            for: RenewedShellTab(kind: .settings, title: "설정", systemImageName: "gearshape")
        )
        let today = factory.makeViewController(
            for: RenewedShellTab(kind: .today, title: "오늘", systemImageName: "figure.walk")
        )

        XCTAssertTrue(settings is RenewedSettingsDashboardViewController)
        XCTAssertTrue(today is RenewedShellPlaceholderViewController)
    }

    func testRenewedTodayDashboardRendersHomeSnapshot() {
        let controller = RenewedTodayDashboardViewController {
            HomeDashboardSnapshot(
                distanceTodayMeters: 1_230,
                distanceTotalMeters: 10_000,
                isTracking: true,
                selectedColorCategoryId: nil,
                generatedAt: Date(timeIntervalSince1970: 100)
            )
        }

        controller.loadViewIfNeeded()

        let texts = controller.view.labelTexts()
        XCTAssertTrue(texts.contains("오늘의 발자취"))
        XCTAssertTrue(texts.contains("1.23km"))
        XCTAssertTrue(texts.contains("전체 10km"))
        XCTAssertTrue(texts.contains("기록 중"))
    }

    func testRenewedSettingsDashboardRendersPreferencesSnapshot() {
        let controller = RenewedSettingsDashboardViewController {
            SettingsPreferencesSnapshot(
                isCloudBackupOptedIn: false,
                featureFlags: FeatureFlags(
                    isCloudBackupEnabled: true,
                    isRestoreEnabled: false,
                    isAuthEnabled: false,
                    isDevelopmentUploadEnabled: false,
                    isNewUIRunwayEnabled: true
                )
            )
        }

        controller.loadViewIfNeeded()

        let texts = controller.view.labelTexts()
        XCTAssertTrue(texts.contains("설정"))
        XCTAssertTrue(texts.contains("백업 꺼짐"))
        XCTAssertTrue(texts.contains("백업 기능 준비됨"))
        XCTAssertTrue(texts.contains("복원 기능 비활성"))
        XCTAssertTrue(texts.contains("계정 연결 비활성"))
    }

    func testLegacyRenewedShellStoryboardSceneProviderMapsExistingStoryboardTabs() {
        let provider = LegacyRenewedShellStoryboardSceneProvider()

        XCTAssertEqual(
            provider.sceneDescriptor(for: RenewedShellTab(kind: .today, title: "", systemImageName: "")),
            StoryboardSceneDescriptor(storyboardName: "Home", viewControllerIdentifier: "HomeViewController")
        )
        XCTAssertEqual(
            provider.sceneDescriptor(for: RenewedShellTab(kind: .timeline, title: "", systemImageName: "")),
            StoryboardSceneDescriptor(storyboardName: "Date", viewControllerIdentifier: "DateViewController")
        )
        XCTAssertEqual(
            provider.sceneDescriptor(for: RenewedShellTab(kind: .stats, title: "", systemImageName: "")),
            StoryboardSceneDescriptor(storyboardName: "Stats", viewControllerIdentifier: "StatsViewController")
        )
        XCTAssertEqual(
            provider.sceneDescriptor(for: RenewedShellTab(kind: .settings, title: "", systemImageName: "")),
            StoryboardSceneDescriptor(storyboardName: "Settings", viewControllerIdentifier: "SettingsViewController")
        )
        XCTAssertNil(provider.sceneDescriptor(for: RenewedShellTab(kind: .map, title: "", systemImageName: "")))
    }

    func testLegacyRootStoryboardDescriptorsPreserveCurrentLaunchSources() {
        XCTAssertEqual(
            StoryboardSceneDescriptor.legacyMainTabs,
            StoryboardSceneDescriptor(storyboardName: "Main", viewControllerIdentifier: "TabBarController")
        )
        XCTAssertEqual(
            StoryboardSceneDescriptor.legacyFirstLaunch,
            StoryboardSceneDescriptor(storyboardName: "FirstLaunch", viewControllerIdentifier: "FL_VideoVC")
        )
        XCTAssertEqual(
            StoryboardSceneDescriptor.legacyPasswordUnlock,
            StoryboardSceneDescriptor(storyboardName: "Main", viewControllerIdentifier: "PasswordVC")
        )
    }

    func testStoryboardBackedRenewedShellFactoryUsesStoryboardInstantiatorForMappedTab() {
        let instantiator = FakeStoryboardSceneInstantiator()
        let expectedController = UIViewController()
        instantiator.controller = expectedController
        let factory = StoryboardBackedRenewedShellViewControllerFactory(
            storyboardInstantiator: instantiator,
            directViewControllerProvider: EmptyDirectViewControllerProvider()
        )

        let controller = factory.makeViewController(
            for: RenewedShellTab(kind: .today, title: "오늘", systemImageName: "figure.walk")
        )

        XCTAssertTrue(controller === expectedController)
        XCTAssertEqual(
            instantiator.instantiatedDescriptors,
            [StoryboardSceneDescriptor(storyboardName: "Home", viewControllerIdentifier: "HomeViewController")]
        )
    }

    func testStoryboardBackedRenewedShellFactoryUsesDirectProviderBeforeStoryboard() {
        let instantiator = FakeStoryboardSceneInstantiator()
        let directProvider = FakeDirectViewControllerProvider()
        let factory = StoryboardBackedRenewedShellViewControllerFactory(
            storyboardInstantiator: instantiator,
            directViewControllerProvider: directProvider,
            fallbackFactory: FakeRenewedShellViewControllerFactory()
        )

        let controller = factory.makeViewController(
            for: RenewedShellTab(kind: .map, title: "지도", systemImageName: "map")
        )

        XCTAssertTrue(controller is FakeDirectViewController)
        XCTAssertTrue(instantiator.instantiatedDescriptors.isEmpty)
    }

    func testStoryboardBackedRenewedShellFactoryFallsBackForUnmappedTab() {
        let instantiator = FakeStoryboardSceneInstantiator()
        let factory = StoryboardBackedRenewedShellViewControllerFactory(
            sceneProvider: EmptyStoryboardSceneProvider(),
            storyboardInstantiator: instantiator,
            directViewControllerProvider: EmptyDirectViewControllerProvider(),
            fallbackFactory: FakeRenewedShellViewControllerFactory()
        )

        let controller = factory.makeViewController(
            for: RenewedShellTab(kind: .map, title: "지도", systemImageName: "map")
        )

        XCTAssertTrue(controller is FakeFallbackViewController)
        XCTAssertTrue(instantiator.instantiatedDescriptors.isEmpty)
    }

    func testRenewedShellCoordinatorBuildsTabBarRootWithoutRuntimeCutover() {
        let coordinator = RenewedShellCoordinator(
            presentation: RenewedShellPresentation(
                tabs: [RenewedShellTab(kind: .map, title: "지도", systemImageName: "map")]
            ),
            viewControllerFactory: FakeRenewedShellViewControllerFactory()
        )

        let root = coordinator.makeRootViewController()

        XCTAssertTrue(root is RenewedShellViewController)
    }

    func testStoryboardLegacyRootFactoryUsesCentralStoryboardDescriptors() {
        let instantiator = RoutingStoryboardSceneInstantiator()
        let mainTabs = UITabBarController()
        let firstLaunch = UIViewController()
        let password = PasswordVC()
        instantiator.controllers = [
            .legacyMainTabs: mainTabs,
            .legacyFirstLaunch: firstLaunch,
            .legacyPasswordUnlock: password
        ]
        let factory = StoryboardLegacyRootViewControllerFactory(storyboardInstantiator: instantiator)

        XCTAssertTrue(factory.makeMainTabs() === mainTabs)
        XCTAssertTrue(factory.makeFirstLaunch() === firstLaunch)
        XCTAssertTrue(factory.makePasswordUnlock() === password)
        XCTAssertEqual(
            instantiator.instantiatedDescriptors,
            [.legacyMainTabs, .legacyFirstLaunch, .legacyPasswordUnlock]
        )
    }
}

private final class FakeStoryboardSceneInstantiator: StoryboardSceneInstantiating {
    var controller = UIViewController()
    private(set) var instantiatedDescriptors: [StoryboardSceneDescriptor] = []

    func instantiate(_ descriptor: StoryboardSceneDescriptor) -> UIViewController {
        instantiatedDescriptors.append(descriptor)
        return controller
    }
}

private final class RoutingStoryboardSceneInstantiator: StoryboardSceneInstantiating {
    var controllers: [StoryboardSceneDescriptor: UIViewController] = [:]
    private(set) var instantiatedDescriptors: [StoryboardSceneDescriptor] = []

    func instantiate(_ descriptor: StoryboardSceneDescriptor) -> UIViewController {
        instantiatedDescriptors.append(descriptor)
        return controllers[descriptor] ?? UIViewController()
    }
}

private struct EmptyStoryboardSceneProvider: RenewedShellStoryboardSceneProviding {
    func sceneDescriptor(for tab: RenewedShellTab) -> StoryboardSceneDescriptor? {
        nil
    }
}

private struct EmptyDirectViewControllerProvider: RenewedShellDirectViewControllerProviding {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController? {
        nil
    }
}

private struct FakeDirectViewControllerProvider: RenewedShellDirectViewControllerProviding {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController? {
        FakeDirectViewController()
    }
}

private struct FakeRenewedShellViewControllerFactory: RenewedShellViewControllerFactory {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        FakeFallbackViewController()
    }
}

private struct FakeHomeDashboardUseCase: HomeDashboardUseCase {
    var snapshot: HomeDashboardSnapshot

    func loadSnapshot() -> HomeDashboardSnapshot {
        snapshot
    }
}

private final class FakeSettingsPreferencesUseCase: SettingsPreferencesUseCase {
    private var snapshotValue: SettingsPreferencesSnapshot

    init(snapshot: SettingsPreferencesSnapshot) {
        snapshotValue = snapshot
    }

    func loadPreferences() -> SettingsPreferencesSnapshot {
        snapshotValue
    }

    func setCloudBackupOptIn(_ isOptedIn: Bool) {
        snapshotValue.isCloudBackupOptedIn = isOptedIn
    }
}

private final class FakeDirectViewController: UIViewController {}
private final class FakeFallbackViewController: UIViewController {}

private extension UIView {
    func labelTexts() -> [String] {
        let ownText = (self as? UILabel)?.text.map { [$0] } ?? []
        return subviews.reduce(ownText) { partialResult, subview in
            partialResult + subview.labelTexts()
        }
    }
}
