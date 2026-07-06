//
//  RenewedAboutViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedAboutViewController: UIViewController {
    private let legacyVersionCode: () -> Int
    private let titleLabel = UILabel()
    private let versionLabel = UILabel()
    private let privacyLabel = UILabel()
    private let contactLabel = UILabel()

    init(legacyVersionCode: @escaping () -> Int) {
        self.legacyVersionCode = legacyVersionCode
        super.init(nibName: nil, bundle: nil)
        title = "앱 정보"
        tabBarItem = UITabBarItem(title: "정보", image: UIImage(systemName: "info.circle"), selectedImage: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureLayout()
        render(versionCode: legacyVersionCode())
    }

    private func configureLayout() {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            versionLabel,
            privacyLabel,
            contactLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [versionLabel, privacyLabel, contactLabel].forEach { label in
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

    private func render(versionCode: Int) {
        titleLabel.text = "앱 정보"
        versionLabel.text = AppVersionPresentation(legacyVersionCode: versionCode).text
        privacyLabel.text = "개인정보 취급방침"
        contactLabel.text = "문의하기"
    }
}
