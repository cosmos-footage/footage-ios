//
//  RepositoryProtocols.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation
import RealmSwift

protocol RouteRepository {
    func loadTodayData()
    func update(footstep: Footstep, distance: Double) throws
    func loadJourneys(rangeOf: String) -> [Journey]
    func calculateDistance(from: Footstep, to: Footstep) -> Double
}

protocol DaySummaryRepository {
    func loadDistance(total: Bool) -> Double
    func loadMonthlyDistance() -> Double
    func saveTotalDistance(value: Double) throws
    func makeTodaySummaryDraft(installationId: InstallationID) -> DaySummaryDraft
}

protocol DeviceIdentityRepository {
    func installationId() -> InstallationID
    func ownerId() -> OwnerID?
    func deviceId() -> DeviceID?
    func save(ownerId: OwnerID?, deviceId: DeviceID?)
}

protocol MigrationExportRepository {
    func exportCurrentRealmData(installationId: InstallationID) -> MigrationExportDraft
}

protocol SyncOutboxRepository {
    func enqueue(_ draft: SyncOutboxDraft) throws
    func pendingBatches() -> [SyncOutboxDraft]
    func update(_ draft: SyncOutboxDraft) throws
}

protocol ColorRepository {
    func update(hex: String, distance: Double) throws
    func distance(hex: String, startDate: Int, endDate: Int) -> Double
    func rankingDistance(startDate: Int, endDate: Int) -> [(key: String, value: Double)]
}

protocol PlaceRepository {
    func update(latitude: Double, longitude: Double, distance: Double)
    func distance(value: String, startDate: Int, endDate: Int) -> Double
    func rankingDistance(startDate: Int, endDate: Int) -> [(key: String, value: Double)]
}

protocol MediaRepository {
    func appendPhoto(_ photo: Data, to footstep: Footstep) throws
    func replaceNote(_ note: String, at index: Int, in footstep: Footstep) throws
    func removeAsset(at index: Int, from footstep: Footstep) throws
}

protocol BadgeRepository {
    func add(_ badge: Badge) throws
    func containsBadge(imageName: String) -> Bool
    func badges() -> [Badge]
}

protocol WidgetStateStore {
    var isTracking: Bool { get set }
    var distanceToday: Double { get set }
    var distanceTotal: Double { get set }
    var selectedColor: String? { get set }
}
