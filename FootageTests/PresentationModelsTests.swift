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
}
