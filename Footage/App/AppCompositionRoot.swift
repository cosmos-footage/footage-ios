//
//  AppCompositionRoot.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct AppCompositionRoot {
    let environment: AppEnvironment

    init(environment: AppEnvironment = .current) {
        self.environment = environment
    }

    func makeCloudBackupConfiguration() -> CloudBackupConfiguration {
        return CloudBackupConfiguration(
            baseURL: environment.cloudBackupBaseURL,
            isCloudBackupEnabled: environment.featureFlags.isCloudBackupEnabled,
            isDevelopmentUploadEnabled: environment.featureFlags.isDevelopmentUploadEnabled,
            requestTimeout: environment.cloudBackupRequestTimeout,
            schemaVersion: environment.cloudBackupSchemaVersion
        )
    }

    func makeRestoreConfiguration() -> CloudBackupConfiguration {
        return makeCloudBackupConfiguration(
            isCloudBackupEnabled: environment.featureFlags.isCloudBackupEnabled
                && environment.featureFlags.isRestoreEnabled,
            isDevelopmentUploadEnabled: false
        )
    }

    func makeAuthConfiguration() -> CloudBackupConfiguration {
        return makeCloudBackupConfiguration(
            isCloudBackupEnabled: environment.featureFlags.isCloudBackupEnabled
                && environment.featureFlags.isAuthEnabled,
            isDevelopmentUploadEnabled: false
        )
    }

    func makeCloudBackupService(
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        syncOutboxRepository: SyncOutboxRepository = LocalSyncOutboxRepository(),
        tokenStore: CloudBackupTokenStore = KeychainCloudBackupTokenStore()
    ) -> CloudBackupService {
        let configuration = makeCloudBackupConfiguration()
        return CloudBackupService(
            configuration: configuration,
            apiClient: apiClient,
            identityRepository: identityRepository,
            syncOutboxRepository: syncOutboxRepository,
            tokenStore: tokenStore
        )
    }

    func makeRestoreService(
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        parser: RoutePointRestoreParser = RoutePointRestoreParser(),
        importRepository: RestoreImportRepository = LocalRestoreImportRepository()
    ) -> RestoreService {
        let configuration = makeRestoreConfiguration()
        return RestoreService(
            configuration: configuration,
            apiClient: apiClient,
            identityRepository: identityRepository,
            parser: parser,
            importRepository: importRepository
        )
    }

    func makeAuthLinkingService(
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        authIdentityStore: AuthIdentityStore = LocalAuthIdentityStore()
    ) -> AuthLinkingService {
        let configuration = makeAuthConfiguration()
        return AuthLinkingService(
            configuration: configuration,
            apiClient: apiClient,
            identityRepository: identityRepository,
            authIdentityStore: authIdentityStore
        )
    }

    private func makeCloudBackupConfiguration(
        isCloudBackupEnabled: Bool,
        isDevelopmentUploadEnabled: Bool
    ) -> CloudBackupConfiguration {
        return CloudBackupConfiguration(
            baseURL: environment.cloudBackupBaseURL,
            isCloudBackupEnabled: isCloudBackupEnabled,
            isDevelopmentUploadEnabled: isDevelopmentUploadEnabled,
            requestTimeout: environment.cloudBackupRequestTimeout,
            schemaVersion: environment.cloudBackupSchemaVersion
        )
    }
}
