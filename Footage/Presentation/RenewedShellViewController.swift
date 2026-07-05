//
//  RenewedShellViewController.swift
//  footage
//
//  Created by Codex on 2026/07/05.
//

import UIKit

final class RenewedShellViewController: UITabBarController {
    private let presentation: RenewedShellPresentation
    private let viewControllerFactory: any RenewedShellViewControllerFactory

    init(
        presentation: RenewedShellPresentation = .default,
        viewControllerFactory: any RenewedShellViewControllerFactory = PlaceholderRenewedShellViewControllerFactory()
    ) {
        self.presentation = presentation
        self.viewControllerFactory = viewControllerFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.presentation = .default
        self.viewControllerFactory = PlaceholderRenewedShellViewControllerFactory()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = presentation.tabs.map { tab in
            let controller = viewControllerFactory.makeViewController(for: tab)
            controller.tabBarItem = UITabBarItem(
                title: tab.title,
                image: UIImage(systemName: tab.systemImageName),
                selectedImage: UIImage(systemName: tab.systemImageName)
            )
            return controller
        }
    }
}

protocol RenewedShellViewControllerFactory {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController
}

struct PlaceholderRenewedShellViewControllerFactory: RenewedShellViewControllerFactory {
    func makeViewController(for tab: RenewedShellTab) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .systemBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.text = tab.title
        controller.view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
        ])

        return controller
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
