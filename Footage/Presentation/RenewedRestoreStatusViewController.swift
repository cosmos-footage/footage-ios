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
        stackView.spacing = 10

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [statusLabel, progressLabel].forEach { label in
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
        }

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func render(status: RestoreStatus) {
        let presentation = RestoreStatusPresentation(status: status)

        titleLabel.text = "복원 상태"
        statusLabel.text = presentation.title
        progressLabel.text = presentation.isInProgress ? "진행 중" : "대기 중"
    }
}
