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
