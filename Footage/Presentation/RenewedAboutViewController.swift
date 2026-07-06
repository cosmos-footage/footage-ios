//
//  RenewedAboutViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedAboutViewController: UIViewController {
    private let legacyVersionCode: () -> Int
    private let makePrivacyPolicyViewController: (() -> UIViewController)?
    private let contactMailPresenter: ContactMailPresenting?
    private let titleLabel = UILabel()
    private let versionLabel = UILabel()
    private let privacyButton = UIButton(type: .system)
    private let contactLabel = UILabel()
    private let contactButton = UIButton(type: .system)

    init(
        legacyVersionCode: @escaping () -> Int,
        makePrivacyPolicyViewController: (() -> UIViewController)? = nil,
        contactMailPresenter: ContactMailPresenting? = nil
    ) {
        self.legacyVersionCode = legacyVersionCode
        self.makePrivacyPolicyViewController = makePrivacyPolicyViewController
        self.contactMailPresenter = contactMailPresenter
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
            privacyButton,
            contactLabel,
            contactButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [versionLabel, contactLabel].forEach { label in
            label.font = .preferredFont(forTextStyle: .body)
            label.adjustsFontForContentSizeCategory = true
            label.textColor = .secondaryLabel
            label.numberOfLines = 0
        }

        privacyButton.setTitle("개인정보 취급방침", for: .normal)
        privacyButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        privacyButton.titleLabel?.adjustsFontForContentSizeCategory = true
        privacyButton.isHidden = makePrivacyPolicyViewController == nil
        privacyButton.addTarget(self, action: #selector(showPrivacyPolicy), for: .touchUpInside)

        contactButton.setTitle("문의하기", for: .normal)
        contactButton.titleLabel?.font = .preferredFont(forTextStyle: .body)
        contactButton.titleLabel?.adjustsFontForContentSizeCategory = true
        contactButton.isHidden = contactMailPresenter == nil
        contactButton.addTarget(self, action: #selector(showContactMail), for: .touchUpInside)
        contactLabel.isHidden = contactMailPresenter != nil

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
        contactLabel.text = "문의하기"
    }

    @objc private func showPrivacyPolicy() {
        guard let makePrivacyPolicyViewController else {
            return
        }

        let viewController = makePrivacyPolicyViewController()
        if let navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            present(viewController, animated: true)
        }
    }

    @objc private func showContactMail() {
        _ = contactMailPresenter?.presentContactMail(from: self)
    }
}
