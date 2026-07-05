//
//  RenewedShellView.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import SwiftUI

struct RenewedShellView: View {
    var presentation: RenewedShellPresentation = .default

    var body: some View {
        TabView {
            ForEach(presentation.tabs) { tab in
                Text(tab.title)
                    .tabItem {
                        Image(systemName: tab.systemImageName)
                        Text(tab.title)
                    }
            }
        }
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
}

struct RenewedShellTab: Identifiable, Equatable {
    var kind: RenewedShellTabKind
    var title: String
    var systemImageName: String

    var id: RenewedShellTabKind {
        kind
    }
}

enum RenewedShellTabKind: String, Equatable, CaseIterable {
    case today
    case map
    case timeline
    case stats
    case settings
}
