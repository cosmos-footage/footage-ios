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
}

struct RealmBadgeRepository: BadgeRepository {
    func add(_ badge: Badge) throws {
        LevelManager.appendBadge(badge: badge)
    }

    func containsBadge(imageName: String) -> Bool {
        LevelManager.checkBadge(badgeName: imageName)
    }

    func badges() -> [Badge] {
        LevelManager.loadBadgeList() ?? []
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

    init?(suiteName: String = "group.footage") {
        guard let defaults = UserDefaults(suiteName: suiteName) else { return nil }
        self.defaults = defaults
    }

    var isTracking: Bool {
        get { defaults.bool(forKey: "isTracking") }
        set { defaults.set(newValue, forKey: "isTracking") }
    }

    var distanceToday: Double {
        get { defaults.double(forKey: "distanceToday") }
        set { defaults.set(newValue, forKey: "distanceToday") }
    }

    var distanceTotal: Double {
        get { defaults.double(forKey: "distanceTotal") }
        set { defaults.set(newValue, forKey: "distanceTotal") }
    }

    var selectedColor: String? {
        get { defaults.string(forKey: "selectedColor") }
        set { defaults.set(newValue, forKey: "selectedColor") }
    }
}
