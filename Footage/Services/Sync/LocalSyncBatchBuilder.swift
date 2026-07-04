//
//  LocalSyncBatchBuilder.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct LocalSyncBatchBuilder {
    private let serializer: RoutePointNDJSONSerializer

    init(serializer: RoutePointNDJSONSerializer = RoutePointNDJSONSerializer()) {
        self.serializer = serializer
    }

    func makeRoutePointItems(
        from export: MigrationExportDraft,
        ownerId: OwnerID?,
        deviceId: DeviceID?,
        configuration: SyncBatchConfiguration = SyncBatchConfiguration()
    ) throws -> [SyncOutboxItem] {
        var items: [SyncOutboxItem] = []

        for day in export.days where !day.points.isEmpty {
            let recordingId = serializer.deterministicRecordingId(
                installationId: export.installationId,
                localDate: day.date
            )
            let records = serializer.records(
                from: day,
                installationId: export.installationId,
                recordingId: recordingId
            )

            for chunk in records.chunked(into: configuration.maxPointsPerBatch) {
                let batch = SyncBatchDraft(
                    ownerId: ownerId,
                    deviceId: deviceId,
                    installationId: export.installationId,
                    schemaVersion: configuration.schemaVersion,
                    routePointCount: chunk.count
                )
                let payload = SyncOutboxPayload(
                    localDate: String(day.date),
                    recordingIds: [recordingId],
                    routePointCount: chunk.count,
                    ndjson: try serializer.ndjson(from: chunk)
                )

                items.append(
                    SyncOutboxItem(
                        syncBatch: batch,
                        type: .routePoints,
                        payload: payload
                    )
                )
            }
        }

        return items
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [self] }

        var chunks: [[Element]] = []
        var index = startIndex

        while index < endIndex {
            let nextIndex = self.index(index, offsetBy: size, limitedBy: endIndex) ?? endIndex
            chunks.append(Array(self[index..<nextIndex]))
            index = nextIndex
        }

        return chunks
    }
}
