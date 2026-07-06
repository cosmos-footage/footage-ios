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
    private let scrollView = UIScrollView()
    private let contentView = UIView()

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
        stackView.spacing = 12

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
        label.numberOfLines = 0
        return label
    }
}
