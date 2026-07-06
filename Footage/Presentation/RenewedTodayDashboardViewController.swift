//
//  RenewedTodayDashboardViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedTodayDashboardViewController: UIViewController {
    private let loadSnapshot: () -> HomeDashboardSnapshot
    private let titleLabel = UILabel()
    private let todayDistanceLabel = UILabel()
    private let totalDistanceLabel = UILabel()
    private let trackingStateLabel = UILabel()

    init(loadSnapshot: @escaping () -> HomeDashboardSnapshot) {
        self.loadSnapshot = loadSnapshot
        super.init(nibName: nil, bundle: nil)
        title = "오늘"
        tabBarItem = UITabBarItem(title: "오늘", image: UIImage(systemName: "figure.walk"), selectedImage: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        render(snapshot: loadSnapshot())
    }

    private func configureLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            todayDistanceLabel,
            totalDistanceLabel,
            trackingStateLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true
        todayDistanceLabel.font = .preferredFont(forTextStyle: .title2)
        todayDistanceLabel.adjustsFontForContentSizeCategory = true
        totalDistanceLabel.font = .preferredFont(forTextStyle: .body)
        totalDistanceLabel.adjustsFontForContentSizeCategory = true
        trackingStateLabel.font = .preferredFont(forTextStyle: .callout)
        trackingStateLabel.adjustsFontForContentSizeCategory = true
        trackingStateLabel.textColor = .secondaryLabel

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func render(snapshot: HomeDashboardSnapshot) {
        let today = HomeDistancePresentation(
            mode: .recordingToday,
            distanceMeters: snapshot.distanceTodayMeters
        )
        let total = HomeDistancePresentation(
            mode: .totalArchive,
            distanceMeters: snapshot.distanceTotalMeters
        )

        titleLabel.text = "오늘의 발자취"
        todayDistanceLabel.text = "\(today.formattedSourceValue)km"
        totalDistanceLabel.text = "전체 \(total.formattedSourceValue)km"
        trackingStateLabel.text = snapshot.isTracking ? "기록 중" : "기록 대기"
    }
}
