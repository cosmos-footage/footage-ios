//
//  LocalSyncOutboxRepository.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum LocalSyncOutboxError: Error {
    case itemNotFound(String)
    case itemIsNotFailed(String)
    case payloadEncodingFailed(String)
}

struct LocalSyncOutboxRepository: SyncOutboxRepository {
    private enum Key {
        static let drafts = "Footage.SyncOutbox.drafts"
        static let items = "Footage.SyncOutbox.items"
        static let lastPreparedAt = "Footage.SyncOutbox.lastPreparedAt"
        static let lastError = "Footage.SyncOutbox.lastError"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let batchBuilder: LocalSyncBatchBuilder
    private let payloadStore: LocalSyncOutboxPayloadStore

    init(
        defaults: UserDefaults = .standard,
        batchBuilder: LocalSyncBatchBuilder = LocalSyncBatchBuilder(),
        payloadStore: LocalSyncOutboxPayloadStore = LocalSyncOutboxPayloadStore()
    ) {
        self.defaults = defaults
        self.batchBuilder = batchBuilder
        self.payloadStore = payloadStore
    }

    func enqueue(_ draft: SyncOutboxDraft) throws {
        var drafts = pendingBatches()
        drafts.append(draft)
        try save(drafts)
    }

    func pendingBatches() -> [SyncOutboxDraft] {
        guard let data = defaults.data(forKey: Key.drafts) else { return [] }
        return (try? decoder.decode([SyncOutboxDraft].self, from: data)) ?? []
    }

    func update(_ draft: SyncOutboxDraft) throws {
        var drafts = pendingBatches()
        if let index = drafts.firstIndex(where: { $0.syncBatchId == draft.syncBatchId }) {
            drafts[index] = draft
        } else {
            drafts.append(draft)
        }
        try save(drafts)
    }

    func enqueue(_ item: SyncOutboxItem) throws {
        let preparedItem = try externalizePayloadIfNeeded(item)
        var items = outboxItems()
        if let index = items.firstIndex(where: { $0.id == preparedItem.id }) {
            items[index] = preparedItem
        } else {
            items.append(preparedItem)
        }
        try save(items)
        defaults.set(Date(), forKey: Key.lastPreparedAt)
    }

    func enqueue(_ items: [SyncOutboxItem]) throws {
        let preparedItems = try items.map { try externalizePayloadIfNeeded($0) }
        var currentItems = outboxItems()
        for item in preparedItems {
            if let index = currentItems.firstIndex(where: { $0.id == item.id }) {
                currentItems[index] = item
            } else {
                currentItems.append(item)
            }
        }
        try save(currentItems)

        if !preparedItems.isEmpty {
            defaults.set(Date(), forKey: Key.lastPreparedAt)
        }
    }

    func outboxItems() -> [SyncOutboxItem] {
        guard let data = defaults.data(forKey: Key.items) else { return [] }
        return (try? decoder.decode([SyncOutboxItem].self, from: data)) ?? []
    }

    func pendingItems() -> [SyncOutboxItem] {
        let now = Date()
        return outboxItems().filter { item in
            guard item.status == .pending || item.status == .syncing else {
                return false
            }

            guard let nextAttemptAt = item.nextAttemptAt else {
                return true
            }

            return nextAttemptAt <= now
        }
    }

    func failedItems() -> [SyncOutboxItem] {
        outboxItems().filter { $0.status == .failed }
    }

    func markSyncing(itemId: String) throws {
        try updateItem(itemId: itemId) { item in
            item.status = .syncing
            item.attemptCount += 1
            item.updatedAt = Date()
            item.nextAttemptAt = nil
            item.lastErrorMessage = nil
        }
    }

    func markSynced(itemId: String) throws {
        try updateItem(itemId: itemId) { item in
            item.status = .synced
            item.updatedAt = Date()
            item.nextAttemptAt = nil
            item.lastErrorMessage = nil
        }
    }

    func markFailed(itemId: String, errorMessage: String) throws {
        defaults.set(errorMessage, forKey: Key.lastError)
        try updateItem(itemId: itemId) { item in
            item.status = .failed
            item.updatedAt = Date()
            item.nextAttemptAt = nextAttemptDate(afterAttempts: item.attemptCount)
            item.lastErrorMessage = errorMessage
        }
    }

    func retryFailed(itemId: String) throws {
        var items = outboxItems()
        guard let index = items.firstIndex(where: { $0.id == itemId }) else {
            throw LocalSyncOutboxError.itemNotFound(itemId)
        }
        guard items[index].status == .failed else {
            throw LocalSyncOutboxError.itemIsNotFailed(itemId)
        }

        items[index].status = .pending
        items[index].updatedAt = Date()
        items[index].nextAttemptAt = nil
        items[index].lastErrorMessage = nil
        try save(items)
    }

    func prepareRoutePointBatches(
        from export: MigrationExportDraft,
        ownerId: OwnerID?,
        deviceId: DeviceID?,
        configuration: SyncBatchConfiguration = SyncBatchConfiguration()
    ) throws -> [SyncOutboxItem] {
        let items = try batchBuilder.makeRoutePointItems(
            from: export,
            ownerId: ownerId,
            deviceId: deviceId,
            configuration: configuration
        )
        try enqueue(items)
        return items
    }

    func localBackupStatus() -> LocalBackupStatus {
        let items = outboxItems()
        return LocalBackupStatus(
            pendingCount: items.filter { $0.status == .pending || $0.status == .syncing }.count,
            failedCount: items.filter { $0.status == .failed }.count,
            lastPreparedAt: defaults.object(forKey: Key.lastPreparedAt) as? Date,
            lastError: defaults.string(forKey: Key.lastError)
        )
    }

    private func save(_ drafts: [SyncOutboxDraft]) throws {
        let data = try encoder.encode(drafts)
        defaults.set(data, forKey: Key.drafts)
    }

    private func save(_ items: [SyncOutboxItem]) throws {
        let data = try encoder.encode(items)
        defaults.set(data, forKey: Key.items)
    }

    private func externalizePayloadIfNeeded(_ item: SyncOutboxItem) throws -> SyncOutboxItem {
        guard let ndjson = item.payload.ndjson else {
            return item
        }

        guard let data = ndjson.data(using: .utf8) else {
            throw LocalSyncOutboxError.payloadEncodingFailed(item.id)
        }

        let fileURL = try payloadStore.writePayload(data, itemId: item.id)
        var preparedItem = item
        preparedItem.payload.ndjson = nil
        preparedItem.payload.localPayloadFilePath = fileURL.path
        preparedItem.payload.payloadContentLength = data.count
        preparedItem.updatedAt = Date()
        return preparedItem
    }

    private func updateItem(itemId: String, mutate: (inout SyncOutboxItem) -> Void) throws {
        var items = outboxItems()
        guard let index = items.firstIndex(where: { $0.id == itemId }) else {
            throw LocalSyncOutboxError.itemNotFound(itemId)
        }

        mutate(&items[index])
        try save(items)
    }

    private func nextAttemptDate(afterAttempts attemptCount: Int) -> Date {
        let clampedAttempts = max(1, min(attemptCount, 6))
        let delay = TimeInterval(60 * (1 << (clampedAttempts - 1)))
        return Date().addingTimeInterval(min(delay, 3_600))
    }
}

struct LocalSyncOutboxPayloadStore {
    private let fileManager: FileManager
    private let rootDirectory: URL?
    private let directoryName: String

    init(
        rootDirectory: URL? = nil,
        directoryName: String = "PrivateSyncOutboxPayloads",
        fileManager: FileManager = .default
    ) {
        self.rootDirectory = rootDirectory
        self.directoryName = directoryName
        self.fileManager = fileManager
    }

    func writePayload(_ data: Data, itemId: String) throws -> URL {
        let directoryURL = try prepareDirectory()
        let fileURL = directoryURL
            .appendingPathComponent(safeFileName(for: itemId))
            .appendingPathExtension("ndjson")

        try data.write(
            to: fileURL,
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )
        try applyFileProtection(to: fileURL)
        try excludeFromDeviceBackup(fileURL)
        return fileURL
    }

    private func prepareDirectory() throws -> URL {
        let directoryURL = try payloadDirectoryURL()
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }
        try applyFileProtection(to: directoryURL)
        try excludeFromDeviceBackup(directoryURL)
        return directoryURL
    }

    private func payloadDirectoryURL() throws -> URL {
        if let rootDirectory = rootDirectory {
            return rootDirectory.appendingPathComponent(directoryName, isDirectory: true)
        }

        let applicationSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return applicationSupportURL.appendingPathComponent(directoryName, isDirectory: true)
    }

    private func safeFileName(for itemId: String) -> String {
        itemId.map { character in
            character.isLetter || character.isNumber || character == "-" || character == "_" ? character : "_"
        }
        .map(String.init)
        .joined()
    }

    private func applyFileProtection(to url: URL) throws {
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }

    private func excludeFromDeviceBackup(_ url: URL) throws {
        var mutableURL = url
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try mutableURL.setResourceValues(resourceValues)
    }
}
