//
//  RenewedAuthReadinessViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedAuthReadinessViewController: UIViewController {
    private let loadSnapshot: () -> AuthLinkingReadinessSnapshot
    private let titleLabel = UILabel()
    private let stateLabel = UILabel()
    private let actionLabel = UILabel()

    init(loadSnapshot: @escaping () -> AuthLinkingReadinessSnapshot) {
        self.loadSnapshot = loadSnapshot
        super.init(nibName: nil, bundle: nil)
        title = "계정 연결 상태"
        tabBarItem = UITabBarItem(title: "계정", image: UIImage(systemName: "person.crop.circle"), selectedImage: nil)
    }

    convenience init(authLinkingReadinessUseCase: AuthLinkingReadinessUseCase) {
        self.init {
            authLinkingReadinessUseCase.snapshot()
        }
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
            stateLabel,
            actionLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [stateLabel, actionLabel].forEach { label in
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

    private func render(snapshot: AuthLinkingReadinessSnapshot) {
        let presentation = AuthLinkingReadinessPresentation(snapshot: snapshot)

        titleLabel.text = "계정 연결 상태"
        stateLabel.text = presentation.title
        actionLabel.text = presentation.actionTitle ?? "계정 연결 비활성"
    }
}
