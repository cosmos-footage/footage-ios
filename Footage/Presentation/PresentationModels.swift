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

enum CityPresentationFallback: Equatable {
    case sejong
    case noData
}

struct CityPresentation: Equatable {
    var sourceName: String
    var imageName: String
    var nicknameText: String

    init(sourceName: String, fallback: CityPresentationFallback) {
        self.sourceName = sourceName

        switch sourceName {
        case "서울특별시", "Seoul":
            imageName = "Seoul"
            nicknameText = "\"서울특별시\""
        case "세종특별자치시", "Sejong City":
            imageName = "Sejong City"
            nicknameText = "\"세종특별자치시\""
        case "제주도", "Jeju":
            imageName = "Jeju"
            nicknameText = "\"제주도\""
        case "경기도", "Gyeonggi-do":
            imageName = "Gyeonggi-do"
            nicknameText = "\"경기도\""
        case "대전광역시", "Daejeon":
            imageName = "Daejeon"
            nicknameText = "\"대전광역시\""
        case "울산광역시", "Ulsan":
            imageName = "Ulsan"
            nicknameText = "\"울산광역시\""
        case "광주광역시", "Gwangju":
            imageName = "Gwangju"
            nicknameText = "\"광주광역시\""
        case "부산광역시", "Busan":
            imageName = "Busan"
            nicknameText = "\"부산광역시\""
        case "대구광역시", "Daegu":
            imageName = "Daegu"
            nicknameText = "\"대구광역시\""
        case "강원도", "Gangwon":
            imageName = "Gangwon"
            nicknameText = "\"강원도\""
        case "인천광역시", "Incheon":
            imageName = "Incheon"
            nicknameText = "\"인천광역시\""
        case "충청북도", "North Chungcheong":
            imageName = "North Chungcheong"
            nicknameText = "\"충청북도\""
        case "경상북도", "North Gyeongsang":
            imageName = "North Gyeongsang"
            nicknameText = "\"경상북도\""
        case "전라북도", "North Jeolla":
            imageName = "North Jeolla"
            nicknameText = "\"전라북도\""
        case "충청남도", "South Chungcheong":
            imageName = "South Chungcheong"
            nicknameText = "\"충청남도\""
        case "경상남도", "South Gyeongsang":
            imageName = "South Gyeongsang"
            nicknameText = "\"경상남도\""
        case "전라남도", "South Jeolla":
            imageName = "South Jeolla"
            nicknameText = "\"전라남도\""
        default:
            switch fallback {
            case .sejong:
                imageName = "Sejong City"
                nicknameText = "\"세종특별자치시\""
            case .noData:
                imageName = "noDataImage"
                nicknameText = "-"
            }
        }
    }
}

enum DistanceTextPresentationStyle: Equatable {
    case integer
    case decimal2
    case integerWithKm
    case decimal2WithKm
}

struct DistanceTextPresentation: Equatable {
    var meters: Double
    var style: DistanceTextPresentationStyle

    var kilometers: Double {
        meters / 1000
    }

    var text: String {
        switch style {
        case .integer:
            return String(format: "%.f", kilometers)
        case .decimal2:
            return String(format: "%.2f", kilometers)
        case .integerWithKm:
            return String(format: "%.f", kilometers) + "km"
        case .decimal2WithKm:
            return String(format: "%.2f", kilometers) + "km"
        }
    }
}

struct ReportButtonPresentation: Equatable {
    var hasData: Bool

    var isEnabled: Bool {
        hasData
    }

    var alpha: Double {
        hasData ? 1 : 0.1
    }
}

struct MapFootstepPresentation: Equatable {
    var legacyDateKey: Int
    var distanceKilometers: Double
    var categoryName: String?
    var photoCount: Int
    var noteCount: Int

    var dateText: String {
        "\(legacyDateKey / 10000)년 \(legacyDateKey % 10000 / 100)월 \(legacyDateKey % 100)일"
    }

    var distanceText: String {
        String(format: "%.2f", distanceKilometers) + "km"
    }

    var photoCountText: String {
        "사진: \(photoCount)"
    }

    var noteCountText: String {
        "글: \(noteCount)"
    }
}

struct CloudBackupStatusPresentation: Equatable {
    var pendingCount: Int
    var failedCount: Int

    var text: String {
        "대기 \(pendingCount) / 실패 \(failedCount)"
    }
}

struct SettingsPushTimePresentation: Equatable {
    var hour: Int
    var minute: Int

    var rowText: String {
        "\(hour)시 \(minute)분"
    }

    func settingsRowText(title: String) -> String {
        title + " :    " + rowText
    }

    static func pickerRowText(_ row: Int) -> String {
        row < 10 ? "0" + String(row) : String(row)
    }
}

struct AppVersionPresentation: Equatable {
    var legacyVersionCode: Int

    var text: String {
        var version = legacyVersionCode
        let hundred = version / 100
        version -= hundred * 100
        let ten = version / 10
        version -= ten * 10
        let one = version

        return "버전정보 " + "v" + String(hundred) + "." + String(ten) + "." + String(one)
    }
}
