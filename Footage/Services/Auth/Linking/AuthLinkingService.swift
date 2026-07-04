//
//  AuthLinkingService.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum AuthLinkingServiceError: Error {
    case authLinkingDisabled
    case missingAnonymousOwner
    case missingBearerToken
    case ownerMismatch
}

protocol AuthIdentityStore {
    func currentIdentity() -> AuthIdentity?
    func save(_ identity: AuthIdentity)
    func state() -> AuthLinkState
    func saveState(_ state: AuthLinkState)
}

struct LocalAuthIdentityStore: AuthIdentityStore {
    private enum Key {
        static let identity = "Footage.Auth.identity"
        static let state = "Footage.Auth.linkState"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func currentIdentity() -> AuthIdentity? {
        guard let data = defaults.data(forKey: Key.identity) else { return nil }
        return try? decoder.decode(AuthIdentity.self, from: data)
    }

    func save(_ identity: AuthIdentity) {
        guard let data = try? encoder.encode(identity) else { return }
        defaults.set(data, forKey: Key.identity)
    }

    func state() -> AuthLinkState {
        guard let rawValue = defaults.string(forKey: Key.state),
              let state = AuthLinkState(rawValue: rawValue) else {
            return .anonymous
        }

        return state
    }

    func saveState(_ state: AuthLinkState) {
        defaults.set(state.rawValue, forKey: Key.state)
    }
}

final class AuthLinkingService {
    private let configuration: CloudBackupConfiguration
    private let apiClient: CloudBackupAPIClientProtocol
    private let identityRepository: DeviceIdentityRepository
    private let authIdentityStore: AuthIdentityStore

    init(
        configuration: CloudBackupConfiguration = CloudBackupConfiguration(),
        apiClient: CloudBackupAPIClientProtocol? = nil,
        identityRepository: DeviceIdentityRepository = LocalDeviceIdentityRepository(),
        authIdentityStore: AuthIdentityStore = LocalAuthIdentityStore()
    ) {
        self.configuration = configuration
        self.apiClient = apiClient ?? CloudBackupAPIClient(configuration: configuration)
        self.identityRepository = identityRepository
        self.authIdentityStore = authIdentityStore
    }

    func link(
        credential: AuthProviderCredential,
        bearerToken: String?,
        completion: @escaping (Result<AuthIdentity, Error>) -> Void
    ) {
        guard configuration.isCloudBackupEnabled else {
            completion(.failure(AuthLinkingServiceError.authLinkingDisabled))
            return
        }

        guard let ownerId = identityRepository.ownerId() else {
            completion(.failure(AuthLinkingServiceError.missingAnonymousOwner))
            return
        }

        guard let bearerToken = bearerToken, !bearerToken.isEmpty else {
            completion(.failure(AuthLinkingServiceError.missingBearerToken))
            return
        }

        authIdentityStore.saveState(.linking)

        let request = AuthLinkRequest(
            ownerId: ownerId.rawValue,
            provider: credential.provider.rawValue,
            providerToken: credential.providerToken,
            authorizationCode: credential.authorizationCode,
            nonce: credential.nonce
        )
        let idempotencyKey = IdempotencyKey(rawValue: "\(ownerId.rawValue):auth-link:\(credential.provider.rawValue)")

        CloudBackupLogger.info("auth link requested")
        apiClient.linkAuth(
            request,
            bearerToken: bearerToken,
            idempotencyKey: idempotencyKey
        ) { [weak self] result in
            switch result {
            case .success(let response):
                guard response.ownerId == ownerId.rawValue else {
                    self?.authIdentityStore.saveState(.failed)
                    completion(.failure(AuthLinkingServiceError.ownerMismatch))
                    return
                }

                let identity = AuthIdentity(
                    provider: AuthProvider(rawValue: response.provider) ?? credential.provider,
                    providerSubject: credential.providerSubject ?? response.authUserId,
                    email: credential.email,
                    linkedAt: response.linkedAt,
                    ownerId: ownerId,
                    authUserId: response.authUserId,
                    isLinked: true
                )
                self?.authIdentityStore.save(identity)
                self?.authIdentityStore.saveState(.linked)
                CloudBackupLogger.info("auth link succeeded")
                completion(.success(identity))
            case .failure(let error):
                self?.authIdentityStore.saveState(.failed)
                CloudBackupLogger.failure(operation: "auth link")
                completion(.failure(error))
            }
        }
    }
}
