//
//  RenewedSettingsDashboardViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedSettingsDashboardViewController: UIViewController {
    private let loadSnapshot: () -> SettingsPreferencesSnapshot
    private let makeBackupStatusViewController: (() -> UIViewController)?
    private let makeRestoreStatusViewController: (() -> UIViewController)?
    private let makeAuthReadinessViewController: (() -> UIViewController)?
    private let makeAboutViewController: (() -> UIViewController)?
    private let titleLabel = UILabel()
    private let backupOptInLabel = UILabel()
    private let backupFeatureLabel = UILabel()
    private let restoreFeatureLabel = UILabel()
    private let authFeatureLabel = UILabel()
    private let backupStatusButton = UIButton(type: .system)
    private let restoreStatusButton = UIButton(type: .system)
    private let authReadinessButton = UIButton(type: .system)
    private let aboutButton = UIButton(type: .system)
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    init(
        loadSnapshot: @escaping () -> SettingsPreferencesSnapshot,
        makeBackupStatusViewController: (() -> UIViewController)? = nil,
        makeRestoreStatusViewController: (() -> UIViewController)? = nil,
        makeAuthReadinessViewController: (() -> UIViewController)? = nil,
        makeAboutViewController: (() -> UIViewController)? = nil
    ) {
        self.loadSnapshot = loadSnapshot
        self.makeBackupStatusViewController = makeBackupStatusViewController
        self.makeRestoreStatusViewController = makeRestoreStatusViewController
        self.makeAuthReadinessViewController = makeAuthReadinessViewController
        self.makeAboutViewController = makeAboutViewController
        super.init(nibName: nil, bundle: nil)
        title = "설정"
        tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape"), selectedImage: nil)
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
            backupOptInLabel,
            backupFeatureLabel,
            restoreFeatureLabel,
            authFeatureLabel,
            backupStatusButton,
            restoreStatusButton,
            authReadinessButton,
            aboutButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [backupOptInLabel, backupFeatureLabel, restoreFeatureLabel, authFeatureLabel].forEach { label in
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
        }

        backupStatusButton.setTitle("백업 상태", for: .normal)
        backupStatusButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        backupStatusButton.titleLabel?.adjustsFontForContentSizeCategory = true
        backupStatusButton.isHidden = makeBackupStatusViewController == nil
        backupStatusButton.addTarget(self, action: #selector(showBackupStatus), for: .touchUpInside)

        restoreStatusButton.setTitle("복원 상태", for: .normal)
        restoreStatusButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        restoreStatusButton.titleLabel?.adjustsFontForContentSizeCategory = true
        restoreStatusButton.isHidden = makeRestoreStatusViewController == nil
        restoreStatusButton.addTarget(self, action: #selector(showRestoreStatus), for: .touchUpInside)

        authReadinessButton.setTitle("계정 연결 상태", for: .normal)
        authReadinessButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        authReadinessButton.titleLabel?.adjustsFontForContentSizeCategory = true
        authReadinessButton.isHidden = makeAuthReadinessViewController == nil
        authReadinessButton.addTarget(self, action: #selector(showAuthReadiness), for: .touchUpInside)

        aboutButton.setTitle("앱 정보", for: .normal)
        aboutButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        aboutButton.titleLabel?.adjustsFontForContentSizeCategory = true
        aboutButton.isHidden = makeAboutViewController == nil
        aboutButton.addTarget(self, action: #selector(showAbout), for: .touchUpInside)

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

    private func render(snapshot: SettingsPreferencesSnapshot) {
        let presentation = SettingsPreferencesPresentation(snapshot: snapshot)

        titleLabel.text = "설정"
        backupOptInLabel.text = presentation.backupOptInText
        backupFeatureLabel.text = presentation.backupFeatureText
        restoreFeatureLabel.text = presentation.restoreFeatureText
        authFeatureLabel.text = presentation.authFeatureText
    }

    @objc private func showBackupStatus() {
        guard let makeBackupStatusViewController else {
            return
        }

        let viewController = makeBackupStatusViewController()
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    @objc private func showRestoreStatus() {
        guard let makeRestoreStatusViewController else {
            return
        }

        let viewController = makeRestoreStatusViewController()
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    @objc private func showAuthReadiness() {
        guard let makeAuthReadinessViewController else {
            return
        }

        let viewController = makeAuthReadinessViewController()
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    @objc private func showAbout() {
        guard let makeAboutViewController else {
            return
        }

        let viewController = makeAboutViewController()
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }
}
