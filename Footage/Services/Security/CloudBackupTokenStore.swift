//
//  CloudBackupTokenStore.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation
import Security

struct CloudBackupTokenRecord: Codable, Equatable {
    var anonymousDeviceToken: String
    var expiresAt: Date?

    func isExpired(referenceDate: Date = Date()) -> Bool {
        guard let expiresAt = expiresAt else {
            return false
        }
        return expiresAt <= referenceDate
    }
}

protocol CloudBackupTokenStore {
    func saveAnonymousDeviceToken(_ token: String, expiresAt: Date?) throws
    func loadAnonymousDeviceToken() throws -> CloudBackupTokenRecord?
    func deleteAnonymousDeviceToken() throws
}

enum SecureTokenStoreError: Error, Equatable {
    case emptyToken
    case encodingFailed
    case decodingFailed
    case keychainStatus(OSStatus)
}

final class KeychainCloudBackupTokenStore: CloudBackupTokenStore {
    private let service: String
    private let account: String
    private let accessGroup: String?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        service: String = "co.el.footage.cloud-backup",
        account: String = "anonymous-device-token",
        accessGroup: String? = nil,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
        self.encoder = encoder
        self.decoder = decoder
    }

    func saveAnonymousDeviceToken(_ token: String, expiresAt: Date?) throws {
        guard !token.isEmpty else {
            throw SecureTokenStoreError.emptyToken
        }

        let record = CloudBackupTokenRecord(
            anonymousDeviceToken: token,
            expiresAt: expiresAt
        )
        let data: Data
        do {
            data = try encoder.encode(record)
        } catch {
            throw SecureTokenStoreError.encodingFailed
        }

        var attributes = baseQuery()
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let addStatus = SecItemAdd(attributes as CFDictionary, nil)
        if addStatus == errSecSuccess {
            return
        }

        guard addStatus == errSecDuplicateItem else {
            throw SecureTokenStoreError.keychainStatus(addStatus)
        }

        let updateStatus = SecItemUpdate(
            baseQuery() as CFDictionary,
            [
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            ] as CFDictionary
        )
        guard updateStatus == errSecSuccess else {
            throw SecureTokenStoreError.keychainStatus(updateStatus)
        }
    }

    func loadAnonymousDeviceToken() throws -> CloudBackupTokenRecord? {
        var query = baseQuery()
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw SecureTokenStoreError.keychainStatus(status)
        }
        guard let data = result as? Data else {
            throw SecureTokenStoreError.decodingFailed
        }

        do {
            return try decoder.decode(CloudBackupTokenRecord.self, from: data)
        } catch {
            throw SecureTokenStoreError.decodingFailed
        }
    }

    func deleteAnonymousDeviceToken() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureTokenStoreError.keychainStatus(status)
        }
    }

    private func baseQuery() -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}
