//
//  DomainModelsTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/05.
//

import XCTest
@testable import footage

final class DomainModelsTests: XCTestCase {
    func testGeoCoordinateValidityUsesCoordinateBounds() {
        XCTAssertTrue(GeoCoordinate(latitude: 37.0, longitude: 127.0).isValid)
        XCTAssertFalse(GeoCoordinate(latitude: 91.0, longitude: 127.0).isValid)
        XCTAssertFalse(GeoCoordinate(latitude: 37.0, longitude: 181.0).isValid)
    }

    func testDebugDescriptionsDoNotExposeSensitivePayloads() {
        let recordingId = RecordingID(rawValue: "rec_test")
        let point = RoutePointEntity(
            pointId: PointID(rawValue: "pt_test"),
            recordingId: recordingId,
            ownerId: nil,
            deviceId: nil,
            timestamp: Date(timeIntervalSince1970: 100),
            coordinate: GeoCoordinate(latitude: 37.12345, longitude: 127.12345),
            horizontalAccuracy: 5,
            altitude: nil,
            speed: nil,
            course: nil,
            colorCategoryId: "#EADE4Cff",
            setAsStart: false,
            sequence: 0,
            syncStatus: .localOnly,
            mediaReferences: [
                MediaReference(
                    assetId: "asset_1",
                    kind: .photo,
                    localIdentifier: "local-photo-id",
                    objectId: "obj_secret",
                    contentType: "image/jpeg",
                    byteSize: 1_024,
                    checksumSha256: "checksum"
                )
            ],
            notes: [
                FootageNote(
                    noteId: "note_1",
                    text: "private note body",
                    createdAt: Date(timeIntervalSince1970: 100),
                    updatedAt: nil
                )
            ]
        )

        let description = point.debugDescription

        XCTAssertFalse(description.contains("37.12345"))
        XCTAssertFalse(description.contains("127.12345"))
        XCTAssertFalse(description.contains("private note body"))
        XCTAssertFalse(description.contains("local-photo-id"))
        XCTAssertFalse(description.contains("obj_secret"))
    }

    func testRecordingLifecycleAcceptingPointsOnlyWhileRecording() {
        XCTAssertTrue(RecordingLifecycleState.recording.isAcceptingPoints)
        XCTAssertFalse(RecordingLifecycleState.idle.isAcceptingPoints)
        XCTAssertFalse(RecordingLifecycleState.paused.isAcceptingPoints)
        XCTAssertFalse(RecordingLifecycleState.stopped.isAcceptingPoints)
    }
}
