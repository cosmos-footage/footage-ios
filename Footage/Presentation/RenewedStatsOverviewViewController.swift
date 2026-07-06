//
//  RenewedStatsOverviewViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedStatsOverviewViewController: UIViewController {
    private let loadSnapshot: () -> StatsOverviewSnapshot
    private let titleLabel = UILabel()
    private let monthlyDistanceLabel = UILabel()
    private let todayDistanceLabel = UILabel()
    private let totalDistanceLabel = UILabel()
    private let topColorLabel = UILabel()
    private let topPlaceLabel = UILabel()

    init(loadSnapshot: @escaping () -> StatsOverviewSnapshot) {
        self.loadSnapshot = loadSnapshot
        super.init(nibName: nil, bundle: nil)
        title = "통계"
        tabBarItem = UITabBarItem(title: "통계", image: UIImage(systemName: "chart.bar"), selectedImage: nil)
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
            monthlyDistanceLabel,
            todayDistanceLabel,
            totalDistanceLabel,
            topColorLabel,
            topPlaceLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [monthlyDistanceLabel, todayDistanceLabel, totalDistanceLabel, topColorLabel, topPlaceLabel].forEach { label in
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
        }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func render(snapshot: StatsOverviewSnapshot) {
        let presentation = StatsOverviewPresentation(snapshot: snapshot)

        titleLabel.text = "통계"
        monthlyDistanceLabel.text = "이번 달 \(presentation.monthlyDistanceText)"
        todayDistanceLabel.text = "오늘 \(presentation.todayDistanceText)"
        totalDistanceLabel.text = "전체 \(presentation.totalDistanceText)"
        topColorLabel.text = "이번 달 대표 색 \(presentation.topColorText)"
        topPlaceLabel.text = "이번 달 대표 장소 \(presentation.topPlaceText)"
    }
}
