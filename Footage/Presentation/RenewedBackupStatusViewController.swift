//
//  RenewedBackupStatusViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedBackupStatusViewController: UIViewController {
    private let loadStatus: () -> LocalBackupStatus
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let lastPreparedLabel = UILabel()
    private let lastErrorLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    init(loadStatus: @escaping () -> LocalBackupStatus) {
        self.loadStatus = loadStatus
        super.init(nibName: nil, bundle: nil)
        title = "백업 상태"
        tabBarItem = UITabBarItem(title: "백업", image: UIImage(systemName: "icloud"), selectedImage: nil)
    }

    convenience init(backupPreparationUseCase: BackupPreparationUseCase) {
        self.init {
            backupPreparationUseCase.status()
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
            lastPreparedLabel,
            lastErrorLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [statusLabel, lastPreparedLabel, lastErrorLabel].forEach { label in
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

    private func render(status: LocalBackupStatus) {
        let presentation = CloudBackupStatusPresentation(
            pendingCount: status.pendingCount,
            failedCount: status.failedCount
        )

        titleLabel.text = "백업 상태"
        statusLabel.text = presentation.text
        lastPreparedLabel.text = status.lastPreparedAt == nil ? "아직 준비된 백업 없음" : "최근 백업 준비 기록 있음"
        lastErrorLabel.text = status.lastError.map { "마지막 오류: \($0)" } ?? "오류 없음"
    }
}
