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
    private let titleLabel = UILabel()
    private let backupOptInLabel = UILabel()
    private let backupFeatureLabel = UILabel()
    private let restoreFeatureLabel = UILabel()
    private let authFeatureLabel = UILabel()
    private let backupStatusButton = UIButton(type: .system)
    private let restoreStatusButton = UIButton(type: .system)

    init(
        loadSnapshot: @escaping () -> SettingsPreferencesSnapshot,
        makeBackupStatusViewController: (() -> UIViewController)? = nil,
        makeRestoreStatusViewController: (() -> UIViewController)? = nil
    ) {
        self.loadSnapshot = loadSnapshot
        self.makeBackupStatusViewController = makeBackupStatusViewController
        self.makeRestoreStatusViewController = makeRestoreStatusViewController
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
            restoreStatusButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

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

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
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
}
