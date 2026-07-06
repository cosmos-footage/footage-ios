//
//  RenewedSettingsDashboardViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedSettingsDashboardViewController: UIViewController {
    private let loadSnapshot: () -> SettingsPreferencesSnapshot
    private let titleLabel = UILabel()
    private let backupOptInLabel = UILabel()
    private let backupFeatureLabel = UILabel()
    private let restoreFeatureLabel = UILabel()
    private let authFeatureLabel = UILabel()

    init(loadSnapshot: @escaping () -> SettingsPreferencesSnapshot) {
        self.loadSnapshot = loadSnapshot
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
            authFeatureLabel
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
}
