//
//  RestoreDuplicateDetector.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct RestoreDuplicateDetector {
    func duplicateCandidateCount(
        incomingPoints: [RoutePointDraft],
        existingPointKeys: Set<String>
    ) -> Int {
        incomingPoints.reduce(0) { count, point in
            existingPointKeys.contains(key(for: point)) ? count + 1 : count
        }
    }

    func key(for point: RoutePointDraft) -> String {
        "\(point.recordingId.rawValue):\(point.pointId.rawValue)"
    }

    func fallbackKey(for point: RoutePointDraft) -> String {
        let roundedLatitude = (point.latitude * 100_000).rounded() / 100_000
        let roundedLongitude = (point.longitude * 100_000).rounded() / 100_000
        return "\(point.timestamp.timeIntervalSince1970):\(roundedLatitude):\(roundedLongitude)"
    }
}
