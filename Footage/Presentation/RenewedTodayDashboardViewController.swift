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
    private let scrollView = UIScrollView()
    private let contentView = UIView()

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

        [todayDistanceLabel, totalDistanceLabel, trackingStateLabel].forEach { label in
            label.numberOfLines = 0
        }

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32)
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
