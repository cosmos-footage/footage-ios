//
//  PresentationModels.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import Foundation

enum JourneyDateGranularity: Equatable {
    case year
    case month
    case day
}

struct JourneyDatePresentation: Equatable {
    var legacyDateKey: Int
    var granularity: JourneyDateGranularity
    var title: String

    init(legacyDateKey: Int) {
        self.legacyDateKey = legacyDateKey

        switch legacyDateKey {
        case ...10000:
            granularity = .year
            title = "\(legacyDateKey)년"
        case 10001...1000000:
            granularity = .month
            title = "\(legacyDateKey / 100)년 \(legacyDateKey % 100)월"
        default:
            granularity = .day
            title = "\(legacyDateKey / 100 % 100)월 \(legacyDateKey % 100)일"
        }
    }
}

struct JourneyTimelineItemPresentation: Equatable {
    var legacyDateKey: Int
    var title: String
    var previewData: Data

    init(legacyDateKey: Int, previewData: Data) {
        let date = JourneyDatePresentation(legacyDateKey: legacyDateKey)
        self.legacyDateKey = legacyDateKey
        title = date.title
        self.previewData = previewData
    }
}

struct JourneyDateDetailPresentation: Equatable {
    var legacyDateKey: Int
    var granularity: JourneyDateGranularity
    var shouldHideMonth: Bool
    var shouldHideDay: Bool
    var yearCounterStart: Int
    var yearCounterEnd: Int
    var monthCounterEnd: Int?
    var dayCounterEnd: Int?

    var shouldPadMonth: Bool {
        guard let monthCounterEnd = monthCounterEnd else { return false }
        return monthCounterEnd < 10
    }

    var shouldPadDay: Bool {
        guard let dayCounterEnd = dayCounterEnd else { return false }
        return dayCounterEnd < 10
    }

    init(legacyDateKey: Int) {
        self.legacyDateKey = legacyDateKey
        let date = JourneyDatePresentation(legacyDateKey: legacyDateKey)
        granularity = date.granularity

        switch date.granularity {
        case .year:
            shouldHideMonth = true
            shouldHideDay = true
            yearCounterStart = 2000
            yearCounterEnd = legacyDateKey
            monthCounterEnd = nil
            dayCounterEnd = nil
        case .month:
            shouldHideMonth = false
            shouldHideDay = true
            yearCounterStart = 2000
            yearCounterEnd = legacyDateKey / 100
            monthCounterEnd = legacyDateKey % 100
            dayCounterEnd = nil
        case .day:
            shouldHideMonth = false
            shouldHideDay = false
            yearCounterStart = 0
            yearCounterEnd = legacyDateKey / 10000 % 100
            monthCounterEnd = legacyDateKey / 100 % 100
            dayCounterEnd = legacyDateKey % 100
        }
    }
}

enum HomeDistancePresentationMode: Equatable {
    case recordingToday
    case totalArchive
}

struct HomeDistancePresentation: Equatable {
    var mode: HomeDistancePresentationMode
    var distanceMeters: Double
    var todayText: String
    var youText: String
    var footText: String
    var valueFormat: String

    var counterValueKilometers: Double {
        distanceMeters / 1000
    }

    var formattedSourceValue: String {
        formattedCounterValue(counterValueKilometers)
    }

    init(mode: HomeDistancePresentationMode, distanceMeters: Double) {
        self.mode = mode
        self.distanceMeters = distanceMeters

        switch mode {
        case .recordingToday:
            todayText = "오늘"
            youText = "당신이 새로 남긴"
            footText = "발자취"
            valueFormat = "%.2f"
        case .totalArchive:
            todayText = "오늘까지"
            youText = "당신이 남긴"
            footText = "발자취"
            valueFormat = "%.f"
        }
    }

    func formattedCounterValue(_ kilometers: Double) -> String {
        String(format: valueFormat, kilometers)
    }
}
