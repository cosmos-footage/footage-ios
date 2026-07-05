//
//  DomainPolicies.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import Foundation

struct RoutePointValidationPolicy {
    enum RejectionReason: Error, Equatable {
        case invalidCoordinate
        case negativeSequence
        case horizontalAccuracyTooLow
        case timestampBeforeRecordingStart
    }

    struct Configuration: Equatable {
        var maximumHorizontalAccuracyMeters: Double = 100
    }

    var configuration: Configuration = Configuration()

    func rejectionReason(
        for point: RoutePointEntity,
        recordingStartedAt: Date
    ) -> RejectionReason? {
        guard point.coordinate.isValid else {
            return .invalidCoordinate
        }

        guard point.sequence >= 0 else {
            return .negativeSequence
        }

        if let horizontalAccuracy = point.horizontalAccuracy,
           horizontalAccuracy > configuration.maximumHorizontalAccuracyMeters {
            return .horizontalAccuracyTooLow
        }

        if point.timestamp < recordingStartedAt {
            return .timestampBeforeRecordingStart
        }

        return nil
    }
}

struct RecordingStateTransitionPolicy {
    enum Event: Equatable {
        case start
        case pause
        case resume
        case stop
        case ingestPoint
    }

    enum RejectionReason: Error, Equatable {
        case cannotStart
        case alreadyRecording
        case cannotPause
        case cannotResume
        case cannotStop
        case cannotIngestPoint
    }

    func transition(
        from state: RecordingLifecycleState,
        event: Event
    ) -> Result<RecordingLifecycleState, RejectionReason> {
        switch (state, event) {
        case (.idle, .start), (.stopped, .start):
            return .success(.recording)
        case (.recording, .pause):
            return .success(.paused)
        case (.paused, .resume):
            return .success(.recording)
        case (.recording, .stop), (.paused, .stop):
            return .success(.stopped)
        case (.recording, .ingestPoint):
            return .success(.recording)
        case (.recording, .start):
            return .failure(.alreadyRecording)
        case (_, .start):
            return .failure(.cannotStart)
        case (_, .pause):
            return .failure(.cannotPause)
        case (_, .resume):
            return .failure(.cannotResume)
        case (_, .stop):
            return .failure(.cannotStop)
        case (_, .ingestPoint):
            return .failure(.cannotIngestPoint)
        }
    }
}

struct BadgeEligibilityPolicy {
    func unlockedMilestones(currentValue: Double, milestones: [Double]) -> [Double] {
        milestones
            .filter { $0 > 0 && currentValue >= $0 }
            .sorted()
    }

    func progress(currentValue: Double, requiredValue: Double) -> Double {
        guard requiredValue > 0 else { return 1 }
        return min(max(currentValue / requiredValue, 0), 1)
    }
}

struct DateGroupingPolicy {
    private var calendar: Calendar

    init(calendar: Calendar = Calendar(identifier: .gregorian)) {
        self.calendar = calendar
    }

    func dayKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
    }

    func monthKey(for date: Date) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", components.year ?? 0, components.month ?? 0)
    }
}

struct ColorCategorySelectionPolicy {
    func selectedCategory(
        requestedId: String?,
        categories: [FootageColorCategory]
    ) -> FootageColorCategory? {
        if let requestedId = requestedId,
           let requested = categories.first(where: { $0.id == requestedId }) {
            return requested
        }

        return categories.sorted { lhs, rhs in
            if lhs.sortOrder == rhs.sortOrder {
                return lhs.id < rhs.id
            }
            return lhs.sortOrder < rhs.sortOrder
        }.first
    }

    func isValidHexRGBA(_ value: String) -> Bool {
        let pattern = #"^#[0-9A-Fa-f]{8}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
