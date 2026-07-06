//
//  RenewedShellPresentation.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

protocol RenewedShellViewControllerFactory {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController
}

struct PlaceholderRenewedShellViewControllerFactory: RenewedShellViewControllerFactory {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        RenewedShellPlaceholderViewController(tab: tab)
    }
}

struct RenewedShellPresentation: Equatable {
    var tabs: [RenewedShellTab]

    static let `default` = RenewedShellPresentation(
        tabs: [
            RenewedShellTab(kind: .today, title: "오늘", systemImageName: "figure.walk"),
            RenewedShellTab(kind: .map, title: "지도", systemImageName: "map"),
            RenewedShellTab(kind: .timeline, title: "기록", systemImageName: "calendar"),
            RenewedShellTab(kind: .stats, title: "통계", systemImageName: "chart.bar"),
            RenewedShellTab(kind: .settings, title: "설정", systemImageName: "gearshape")
        ]
    )

    static let legacyStoryboardBridge = RenewedShellPresentation(
        tabs: [
            RenewedShellTab(kind: .today, title: "홈", systemImageName: "house.fill"),
            RenewedShellTab(kind: .map, title: "지도", systemImageName: "location.fill"),
            RenewedShellTab(kind: .stats, title: "월간 리포트", systemImageName: "rectangle.grid.1x2.fill"),
            RenewedShellTab(kind: .timeline, title: "기록", systemImageName: "person.fill"),
            RenewedShellTab(kind: .settings, title: "설정", systemImageName: "circle.grid.2x2.fill")
        ]
    )
}

struct RenewedShellTab: Equatable {
    var kind: RenewedShellTabKind
    var title: String
    var systemImageName: String
}

enum RenewedShellTabKind: String, Equatable, CaseIterable {
    case today
    case map
    case timeline
    case stats
    case settings
}
