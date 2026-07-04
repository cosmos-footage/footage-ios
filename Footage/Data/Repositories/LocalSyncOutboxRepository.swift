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

    init(defaults: UserDefaults = .standard, batchBuilder: LocalSyncBatchBuilder = LocalSyncBatchBuilder()) {
        self.defaults = defaults
        self.batchBuilder = batchBuilder
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
        var items = outboxItems()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        try save(items)
        defaults.set(Date(), forKey: Key.lastPreparedAt)
    }

    func enqueue(_ items: [SyncOutboxItem]) throws {
        var currentItems = outboxItems()
        for item in items {
            if let index = currentItems.firstIndex(where: { $0.id == item.id }) {
                currentItems[index] = item
            } else {
                currentItems.append(item)
            }
        }
        try save(currentItems)

        if !items.isEmpty {
            defaults.set(Date(), forKey: Key.lastPreparedAt)
        }
    }

    func outboxItems() -> [SyncOutboxItem] {
        guard let data = defaults.data(forKey: Key.items) else { return [] }
        return (try? decoder.decode([SyncOutboxItem].self, from: data)) ?? []
    }

    func pendingItems() -> [SyncOutboxItem] {
        outboxItems().filter { $0.status == .pending }
    }

    func failedItems() -> [SyncOutboxItem] {
        outboxItems().filter { $0.status == .failed }
    }

    func markSyncing(itemId: String) throws {
        try updateItem(itemId: itemId) { item in
            item.status = .syncing
            item.attemptCount += 1
            item.updatedAt = Date()
            item.lastErrorMessage = nil
        }
    }

    func markSynced(itemId: String) throws {
        try updateItem(itemId: itemId) { item in
            item.status = .synced
            item.updatedAt = Date()
            item.lastErrorMessage = nil
        }
    }

    func markFailed(itemId: String, errorMessage: String) throws {
        defaults.set(errorMessage, forKey: Key.lastError)
        try updateItem(itemId: itemId) { item in
            item.status = .failed
            item.updatedAt = Date()
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

    private func updateItem(itemId: String, mutate: (inout SyncOutboxItem) -> Void) throws {
        var items = outboxItems()
        guard let index = items.firstIndex(where: { $0.id == itemId }) else {
            throw LocalSyncOutboxError.itemNotFound(itemId)
        }

        mutate(&items[index])
        try save(items)
    }
}
