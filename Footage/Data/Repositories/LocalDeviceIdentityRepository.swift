//
//  LocalDeviceIdentityRepository.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct LocalDeviceIdentityRepository: DeviceIdentityRepository {
    private enum Key {
        static let installationId = "Footage.Identity.installationId"
        static let ownerId = "Footage.Identity.ownerId"
        static let deviceId = "Footage.Identity.deviceId"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func installationId() -> InstallationID {
        if let existing = defaults.string(forKey: Key.installationId), !existing.isEmpty {
            return InstallationID(rawValue: existing)
        }

        let generated = InstallationID.generate()
        defaults.set(generated.rawValue, forKey: Key.installationId)
        return generated
    }

    func ownerId() -> OwnerID? {
        defaults.string(forKey: Key.ownerId).map(OwnerID.init(rawValue:))
    }

    func deviceId() -> DeviceID? {
        defaults.string(forKey: Key.deviceId).map(DeviceID.init(rawValue:))
    }

    func save(ownerId: OwnerID?, deviceId: DeviceID?) {
        defaults.set(ownerId?.rawValue, forKey: Key.ownerId)
        defaults.set(deviceId?.rawValue, forKey: Key.deviceId)
    }
}
