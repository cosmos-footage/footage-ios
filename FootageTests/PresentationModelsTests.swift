//
//  PresentationModelsTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/05.
//

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
}
