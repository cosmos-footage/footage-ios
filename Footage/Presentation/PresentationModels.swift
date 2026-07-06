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

struct RenewedTimelineItemPresentation: Equatable {
    var journey: JourneyEntity

    var title: String {
        if let legacyDateKey = Int(journey.localDate) {
            return JourneyDatePresentation(legacyDateKey: legacyDateKey).title
        }

        return journey.localDate
    }

    var distanceText: String {
        DistanceTextPresentation(meters: journey.distanceMeters, style: .decimal2WithKm).text
    }

    var detailText: String {
        "점 \(journey.pointCount) / 사진 \(journey.mediaCount) / 글 \(journey.noteCount)"
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

struct SettingsPreferencesPresentation: Equatable {
    var snapshot: SettingsPreferencesSnapshot

    var backupOptInText: String {
        snapshot.isCloudBackupOptedIn ? "백업 사용 중" : "백업 꺼짐"
    }

    var backupFeatureText: String {
        snapshot.featureFlags.isCloudBackupEnabled ? "백업 기능 준비됨" : "백업 기능 비활성"
    }

    var restoreFeatureText: String {
        snapshot.featureFlags.isRestoreEnabled ? "복원 기능 준비됨" : "복원 기능 비활성"
    }

    var authFeatureText: String {
        snapshot.featureFlags.isAuthEnabled ? "계정 연결 준비됨" : "계정 연결 비활성"
    }
}

struct StatsOverviewPresentation: Equatable {
    var snapshot: StatsOverviewSnapshot

    var todayDistanceText: String {
        DistanceTextPresentation(meters: snapshot.distanceTodayMeters, style: .integerWithKm).text
    }

    var totalDistanceText: String {
        DistanceTextPresentation(meters: snapshot.distanceTotalMeters, style: .integerWithKm).text
    }

    var monthlyDistanceText: String {
        DistanceTextPresentation(meters: snapshot.distanceThisMonthMeters, style: .integerWithKm).text
    }

    var topColorText: String {
        snapshot.topColorCategoryId ?? "-"
    }

    var topPlaceText: String {
        snapshot.topPlaceName ?? "-"
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

struct RestoreStatusPresentation: Equatable {
    var status: RestoreStatus

    var title: String {
        switch status {
        case .idle:
            return "복원 대기"
        case .fetchingManifest:
            return "복원 목록 확인 중"
        case .downloading:
            return "복원 데이터 다운로드 중"
        case .parsing:
            return "복원 데이터 확인 중"
        case .readyToImport:
            return "복원 준비 완료"
        case .importing:
            return "복원 중"
        case .completed:
            return "복원 완료"
        case .failed:
            return "복원 실패"
        }
    }

    var isInProgress: Bool {
        switch status {
        case .fetchingManifest, .downloading, .parsing, .importing:
            return true
        case .idle, .readyToImport, .completed, .failed:
            return false
        }
    }
}

struct RestoreImportPlanPresentation: Equatable {
    var plan: RestoreImportPlan

    var recordingCountText: String {
        "기록 \(plan.recordingCount)개"
    }

    var routePointCountText: String {
        "경로점 \(plan.routePointCount)개"
    }

    var duplicateCandidateCountText: String {
        "중복 후보 \(plan.duplicateCandidateCount)개"
    }

    var estimatedImportSizeText: String {
        "예상 크기 \(plan.estimatedImportSizeBytes)B"
    }

    var canImport: Bool {
        plan.canImport
    }

    var requiresUserConfirmation: Bool {
        plan.requiresUserConfirmation
    }
}

struct AuthLinkStatePresentation: Equatable {
    var state: AuthLinkState

    var title: String {
        switch state {
        case .anonymous:
            return "익명 백업 사용 중"
        case .linking:
            return "계정 연결 중"
        case .linked:
            return "계정 연결 완료"
        case .failed:
            return "계정 연결 실패"
        case .unavailable:
            return "계정 연결 불가"
        }
    }
}

struct AuthLinkingReadinessPresentation: Equatable {
    var snapshot: AuthLinkingReadinessSnapshot

    var title: String {
        AuthLinkStatePresentation(state: snapshot.authLinkState).title
    }

    var isActionEnabled: Bool {
        snapshot.canStartLinking
    }

    var actionTitle: String? {
        snapshot.canStartLinking ? "계정 연결" : nil
    }
}

struct BadgePresentation: Equatable {
    var imageName: String
    var detail: String

    var detailText: String {
        detail.isEmpty ? "" : "\"\(detail)\""
    }
}
