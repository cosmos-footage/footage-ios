//
//  AuthLinkingServiceTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import XCTest
@testable import footage

final class AuthLinkingServiceTests: XCTestCase {
    func testLinkRejectsOwnerMismatchAndMarksStateFailed() {
        let apiClient = MockCloudBackupAPIClient()
        apiClient.authLinkResult = .success(
            AuthLinkResponse(
                ownerId: "own_other",
                authUserId: "auth_1",
                provider: "apple",
                linkedAt: Date(timeIntervalSince1970: 100)
            )
        )
        let identityStore = InMemoryAuthIdentityStore()
        let service = AuthLinkingService(
            configuration: CloudBackupConfiguration(
                baseURL: URL(string: "https://example.test")!,
                isCloudBackupEnabled: true
            ),
            apiClient: apiClient,
            identityRepository: FixedDeviceIdentityRepository(ownerId: OwnerID(rawValue: "own_local")),
            authIdentityStore: identityStore
        )
        let expectation = expectation(description: "auth link completion")

        service.link(
            credential: AuthProviderCredential(
                provider: .apple,
                providerSubject: "apple_sub",
                providerToken: "provider_token",
                authorizationCode: nil,
                nonce: nil,
                email: nil
            ),
            bearerToken: "bearer_token"
        ) { result in
            if case .failure(AuthLinkingServiceError.ownerMismatch) = result {
                XCTAssertEqual(identityStore.linkState, .failed)
                XCTAssertNil(identityStore.identity)
            } else {
                XCTFail("Expected owner mismatch failure")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }
}

private final class InMemoryAuthIdentityStore: AuthIdentityStore {
    var identity: AuthIdentity?
    var linkState: AuthLinkState = .anonymous

    func currentIdentity() -> AuthIdentity? {
        identity
    }

    func save(_ identity: AuthIdentity) {
        self.identity = identity
    }

    func state() -> AuthLinkState {
        linkState
    }

    func saveState(_ state: AuthLinkState) {
        linkState = state
    }
}

private struct FixedDeviceIdentityRepository: DeviceIdentityRepository {
    var installation = InstallationID(rawValue: "inst_test")
    var owner: OwnerID?
    var device: DeviceID?

    init(ownerId: OwnerID? = OwnerID(rawValue: "own_1"), deviceId: DeviceID? = DeviceID(rawValue: "dev_1")) {
        owner = ownerId
        device = deviceId
    }

    func installationId() -> InstallationID {
        installation
    }

    func ownerId() -> OwnerID? {
        owner
    }

    func deviceId() -> DeviceID? {
        device
    }

    func save(ownerId: OwnerID?, deviceId: DeviceID?) {}
}

private final class MockCloudBackupAPIClient: CloudBackupAPIClientProtocol {
    var authLinkResult: Result<AuthLinkResponse, Error>?

    func bootstrapInstallation(
        _ request: BootstrapRequest,
        completion: @escaping (Result<BootstrapResponse, Error>) -> Void
    ) {}

    func requestPresignedUpload(
        _ request: PresignUploadRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<PresignUploadResponse, Error>) -> Void
    ) {}

    func uploadDataToPresignedURL(
        data: Data,
        response: PresignUploadResponse,
        contentType: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {}

    func completeUpload(
        _ request: UploadCompleteRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<UploadCompleteResponse, Error>) -> Void
    ) {}

    func registerSyncBatch(
        _ request: SyncBatchRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<SyncBatchResponse, Error>) -> Void
    ) {}

    func requestRestoreManifest(
        ownerId: OwnerID,
        deviceId: DeviceID,
        since: Date?,
        bearerToken: String,
        completion: @escaping (Result<RestoreManifestResponse, Error>) -> Void
    ) {}

    func linkAuth(
        _ request: AuthLinkRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<AuthLinkResponse, Error>) -> Void
    ) {
        completion(authLinkResult ?? .failure(CloudBackupAPIError.missingData))
    }

    func downloadData(
        from url: URL,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {}
}
