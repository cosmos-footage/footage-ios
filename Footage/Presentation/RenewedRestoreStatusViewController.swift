//
//  RenewedRestoreStatusViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedRestoreStatusViewController: UIViewController {
    private let loadStatus: () -> RestoreStatus
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let progressLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    init(loadStatus: @escaping () -> RestoreStatus) {
        self.loadStatus = loadStatus
        super.init(nibName: nil, bundle: nil)
        title = "복원 상태"
        tabBarItem = UITabBarItem(title: "복원", image: UIImage(systemName: "arrow.clockwise.icloud"), selectedImage: nil)
    }

    convenience init(restorePreviewUseCase: RestorePreviewUseCase) {
        self.init {
            restorePreviewUseCase.status()
        }
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        render(status: loadStatus())
    }

    private func configureLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            statusLabel,
            progressLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [statusLabel, progressLabel].forEach { label in
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
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

    private func render(status: RestoreStatus) {
        let presentation = RestoreStatusPresentation(status: status)

        titleLabel.text = "복원 상태"
        statusLabel.text = presentation.title
        progressLabel.text = presentation.isInProgress ? "진행 중" : "대기 중"
    }
}
