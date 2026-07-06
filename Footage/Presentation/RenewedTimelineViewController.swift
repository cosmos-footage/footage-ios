//
//  RenewedTimelineViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedTimelineViewController: UIViewController {
    private let loadJourneys: () -> [JourneyEntity]
    private let stackView = UIStackView()

    init(loadJourneys: @escaping () -> [JourneyEntity]) {
        self.loadJourneys = loadJourneys
        super.init(nibName: nil, bundle: nil)
        title = "기록"
        tabBarItem = UITabBarItem(title: "기록", image: UIImage(systemName: "calendar"), selectedImage: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        render(journeys: loadJourneys())
    }

    private func configureLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func render(journeys: [JourneyEntity]) {
        stackView.arrangedSubviews.forEach { view in
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        let titleLabel = makeLabel(text: "기록", textStyle: .largeTitle, color: .label)
        stackView.addArrangedSubview(titleLabel)

        if journeys.isEmpty {
            stackView.addArrangedSubview(makeLabel(text: "기록 없음", textStyle: .body, color: .secondaryLabel))
            return
        }

        journeys.prefix(5).forEach { journey in
            let presentation = RenewedTimelineItemPresentation(journey: journey)
            stackView.addArrangedSubview(makeLabel(text: presentation.title, textStyle: .headline, color: .label))
            stackView.addArrangedSubview(makeLabel(text: presentation.distanceText, textStyle: .body, color: .secondaryLabel))
            stackView.addArrangedSubview(makeLabel(text: presentation.detailText, textStyle: .caption1, color: .tertiaryLabel))
        }
    }

    private func makeLabel(text: String, textStyle: UIFont.TextStyle, color: UIColor) -> UILabel {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: textStyle)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = color
        label.text = text
        return label
    }
}
