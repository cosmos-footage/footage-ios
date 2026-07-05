//
//  RealmRepositories.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation
import RealmSwift

struct RealmRouteRepository: RouteRepository {
    func loadTodayData() {
        DateManager.loadTodayData()
    }

    func update(footstep: Footstep, distance: Double) throws {
        DateManager.update(footstep: footstep, distance: distance)
    }

    func loadJourneys(rangeOf: String) -> [Journey] {
        DateManager.loadFromRealm(rangeOf: rangeOf)
    }

    func allFootsteps() -> [Footstep] {
        let realm = try! Realm()
        return Array(realm.objects(Footstep.self))
    }

    func footstepsWithAssets() -> [Footstep] {
        allFootsteps().filter { !$0.notes.isEmpty }
    }

    func calculateDistance(from: Footstep, to: Footstep) -> Double {
        DateManager.calculateDistance(from: from, to: to)
    }
}

struct RealmDaySummaryRepository: DaySummaryRepository {
    func loadDistance(total: Bool) -> Double {
        DateManager.loadDistance(total: total)
    }

    func loadMonthlyDistance() -> Double {
        DateManager.loadMonthlyDistance()
    }

    func saveTotalDistance(value: Double) throws {
        DateManager.saveTotalDistance(value: value)
    }

    func makeTodaySummaryDraft(installationId: InstallationID) -> DaySummaryDraft {
        let today = DateConverter.dateToDay(date: Date())
        let todayJourneys = DateManager.loadFromRealm(rangeOf: String(today))
        let pointCount = todayJourneys.reduce(0) { $0 + $1.footsteps.count }

        return DaySummaryDraft(
            localDate: String(today),
            ownerId: nil,
            deviceId: nil,
            distanceMeters: DateManager.loadDistance(total: false),
            recordingCount: todayJourneys.isEmpty ? 0 : 1,
            pointCount: pointCount,
            previewAssetId: nil,
            syncStatus: .localOnly
        )
    }
}

struct RealmColorRepository: ColorRepository {
    func update(hex: String, distance: Double) throws {
        ColorManager.update(hex: hex, distance: distance)
    }

    func distance(hex: String, startDate: Int, endDate: Int) -> Double {
        ColorManager.getDistance(hex: hex, startDate: startDate, endDate: endDate)
    }

    func rankingDistance(startDate: Int, endDate: Int) -> [(key: String, value: Double)] {
        ColorManager.getRankingDistance(startDate: startDate, endDate: endDate)
    }

    func footsteps(hex: String, from startDate: Int, to endDate: Int) -> [List<Footstep>] {
        ColorManager.footstepsWithColor(color: hex, from: startDate, to: endDate)
    }
}

struct RealmPlaceRepository: PlaceRepository {
    func update(latitude: Double, longitude: Double, distance: Double) {
        PlaceManager.update(latitude: latitude, longitude: longitude, distance: distance)
    }

    func distance(value: String, startDate: Int, endDate: Int) -> Double {
        PlaceManager.getDistance(key: "key", value: value, startDate: startDate, endDate: endDate)
    }

    func rankingDistance(startDate: Int, endDate: Int) -> [(key: String, value: Double)] {
        PlaceManager.getRankingDistance(startDate: startDate, endDate: endDate)
    }
}

struct RealmMediaRepository: MediaRepository {
    func appendPhoto(_ photo: Data, to footstep: Footstep) throws {
        let realm = try Realm()
        try realm.write {
            footstep.photos.append(photo)
            footstep.notes.append("")
        }
    }

    func replaceNote(_ note: String, at index: Int, in footstep: Footstep) throws {
        guard footstep.notes.indices.contains(index) else { return }

        let realm = try Realm()
        try realm.write {
            footstep.notes.replace(index: index, object: note)
        }
    }

    func removeAsset(at index: Int, from footstep: Footstep) throws {
        guard footstep.photos.indices.contains(index), footstep.notes.indices.contains(index) else { return }

        let realm = try Realm()
        try realm.write {
            footstep.photos.remove(at: index)
            footstep.notes.remove(at: index)
        }
    }

    func removeAllAssets(from footstep: Footstep) throws {
        let realm = try Realm()
        try realm.write {
            footstep.photos.removeAll()
            footstep.notes.removeAll()
        }
    }
}

struct RealmJourneyPreviewRepository: JourneyPreviewRepository {
    func savePreview(_ preview: Data, for journey: Journey) throws {
        let realm = try Realm()
        try realm.write {
            if let day = journey.reference as? DayData {
                day.preview = preview
            } else if let month = journey.reference as? Month {
                month.preview = preview
            } else if let year = journey.reference as? Year {
                year.preview = preview
            }
        }
    }
}

struct RealmBadgeRepository: BadgeRepository {
    func add(_ badge: Badge) throws {
        LevelManager.appendBadge(badge: badge)
    }

    func badge(imageName: String) -> Badge? {
        LevelManager.loadTodayBadge(imageName: imageName)
    }

    func containsBadge(imageName: String) -> Bool {
        LevelManager.checkBadge(badgeName: imageName)
    }

    func badges() -> [Badge] {
        LevelManager.loadBadgeList() ?? []
    }

    func monthlyBadges(month: String) -> [Badge]? {
        LevelManager.callMonthlyBadge(month: month)
    }
}

struct RealmMigrationExportRepository: MigrationExportRepository {
    func exportCurrentRealmData(installationId: InstallationID) -> MigrationExportDraft {
        let days = DateManager.loadFromRealm(rangeOf: "day").map { journey in
            DayExportDraft(
                date: Int(journey.date),
                distanceMeters: (journey.reference as? DayData)?.distance ?? 0,
                points: journey.footsteps.map { footstep in
                    RoutePointExportDraft(
                        timestamp: footstep.timestamp,
                        latitude: footstep.latitude,
                        longitude: footstep.longitude,
                        color: footstep.color,
                        setAsStart: footstep.setAsStart,
                        photoCount: footstep.photos.count,
                        noteCount: footstep.notes.count
                    )
                }
            )
        }

        return MigrationExportDraft(
            exportedAt: Date(),
            installationId: installationId,
            days: days
        )
    }
}

struct AppGroupWidgetStateStore: WidgetStateStore {
    private let defaults: UserDefaults

    init?(suiteName: String = AppGroupWidgetStateKeys.suiteName) {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return nil }
        self.defaults = defaults
    }

    var isTracking: Bool {
        get { defaults.bool(forKey: AppGroupWidgetStateKeys.isTracking) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.isTracking) }
    }

    var distanceToday: Double {
        get { defaults.double(forKey: AppGroupWidgetStateKeys.distanceToday) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.distanceToday) }
    }

    var distanceTotal: Double {
        get { defaults.double(forKey: AppGroupWidgetStateKeys.distanceTotal) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.distanceTotal) }
    }

    var selectedColor: String? {
        get { defaults.string(forKey: AppGroupWidgetStateKeys.selectedColor) }
        set { defaults.set(newValue, forKey: AppGroupWidgetStateKeys.selectedColor) }
    }
}
