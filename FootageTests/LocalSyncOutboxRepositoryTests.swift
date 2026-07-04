//
//  LocalSyncOutboxRepositoryTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import XCTest
@testable import footage

final class LocalSyncOutboxRepositoryTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!
    private var payloadRoot: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "FootageTests.LocalSyncOutboxRepository.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        payloadRoot = FileManager.default.temporaryDirectory.appendingPathComponent(suiteName, isDirectory: true)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        if let payloadRoot = payloadRoot {
            try? FileManager.default.removeItem(at: payloadRoot)
        }
        defaults = nil
        suiteName = nil
        payloadRoot = nil
        try super.tearDownWithError()
    }

    func testMarkFailedStoresBackoffAndExcludesFromPendingUntilRetry() throws {
        let repository = makeRepository()
        let item = makeItem()

        try repository.enqueue(item)
        try repository.markSyncing(itemId: item.id)
        try repository.markFailed(itemId: item.id, errorMessage: "network failed")

        let failedItem = try XCTUnwrap(repository.failedItems().first)
        XCTAssertEqual(failedItem.status, .failed)
        XCTAssertEqual(failedItem.attemptCount, 1)
        XCTAssertNotNil(failedItem.nextAttemptAt)
        XCTAssertEqual(failedItem.lastErrorMessage, "network failed")
        XCTAssertTrue(repository.pendingItems().isEmpty)

        try repository.retryFailed(itemId: item.id)

        let retryItem = try XCTUnwrap(repository.pendingItems().first)
        XCTAssertEqual(retryItem.status, .pending)
        XCTAssertNil(retryItem.nextAttemptAt)
        XCTAssertNil(retryItem.lastErrorMessage)
    }

    func testEnqueueExternalizesInlineNDJSONPayload() throws {
        let repository = makeRepository()
        let item = makeItem(payload: SyncOutboxPayload(ndjson: #"{"pointId":"pt_1"}"#))

        try repository.enqueue(item)

        let storedItem = try XCTUnwrap(repository.outboxItems().first)
        XCTAssertNil(storedItem.payload.ndjson)
        let path = try XCTUnwrap(storedItem.payload.localPayloadFilePath)
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
        XCTAssertEqual(storedItem.payload.payloadContentLength, #"{"pointId":"pt_1"}"#.utf8.count)
    }

    private func makeRepository() -> LocalSyncOutboxRepository {
        LocalSyncOutboxRepository(
            defaults: defaults,
            payloadStore: LocalSyncOutboxPayloadStore(rootDirectory: payloadRoot)
        )
    }

    private func makeItem(
        payload: SyncOutboxPayload = SyncOutboxPayload(routePointCount: 1)
    ) -> SyncOutboxItem {
        let batch = SyncBatchDraft(
            syncBatchId: SyncBatchID(rawValue: "batch_test"),
            installationId: InstallationID(rawValue: "inst_test")
        )
        return SyncOutboxItem(
            id: "item_test",
            syncBatch: batch,
            type: .routePoints,
            payload: payload,
            createdAt: Date(timeIntervalSince1970: 100),
            updatedAt: Date(timeIntervalSince1970: 100)
        )
    }
}
