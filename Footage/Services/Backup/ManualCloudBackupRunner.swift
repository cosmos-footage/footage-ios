//
//  ManualCloudBackupRunner.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct ManualBackupPreparationResult: Equatable {
    let preparedItemCount: Int
    let localBackupStatus: LocalBackupStatus
}

protocol ManualCloudBackupRunning {
    func prepareLocalRouteBackup(configuration: SyncBatchConfiguration) throws -> ManualBackupPreparationResult
    func localBackupStatus() -> LocalBackupStatus
}

final class ManualCloudBackupRunner: ManualCloudBackupRunning {
    private let identityRepository: DeviceIdentityRepository
    private let migrationExportRepository: MigrationExportRepository
    private let syncOutboxRepository: SyncOutboxRepository

    init(
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        migrationExportRepository: MigrationExportRepository = RealmMigrationExportRepository(),
        syncOutboxRepository: SyncOutboxRepository = LocalSyncOutboxRepository()
    ) {
        self.identityRepository = identityRepository
        self.migrationExportRepository = migrationExportRepository
        self.syncOutboxRepository = syncOutboxRepository
    }

    func prepareLocalRouteBackup(
        configuration: SyncBatchConfiguration = SyncBatchConfiguration()
    ) throws -> ManualBackupPreparationResult {
        let installationId = identityRepository.installationId()
        let export = migrationExportRepository.exportCurrentRealmData(installationId: installationId)
        let preparedItems = try syncOutboxRepository.prepareRoutePointBatches(
            from: export,
            ownerId: identityRepository.ownerId(),
            deviceId: identityRepository.deviceId(),
            configuration: configuration
        )

        return ManualBackupPreparationResult(
            preparedItemCount: preparedItems.count,
            localBackupStatus: syncOutboxRepository.localBackupStatus()
        )
    }

    func localBackupStatus() -> LocalBackupStatus {
        syncOutboxRepository.localBackupStatus()
    }
}
