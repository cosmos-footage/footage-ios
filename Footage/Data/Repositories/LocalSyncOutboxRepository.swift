//
//  LocalSyncOutboxRepository.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct LocalSyncOutboxRepository: SyncOutboxRepository {
    private enum Key {
        static let drafts = "Footage.SyncOutbox.drafts"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
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

    private func save(_ drafts: [SyncOutboxDraft]) throws {
        let data = try encoder.encode(drafts)
        defaults.set(data, forKey: Key.drafts)
    }
}
