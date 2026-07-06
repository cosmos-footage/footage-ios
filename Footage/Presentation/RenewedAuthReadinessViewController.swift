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
    private let scrollView = UIScrollView()
    private let contentView = UIView()

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
        stackView.spacing = 12

        titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
        titleLabel.adjustsFontForContentSizeCategory = true

        [stateLabel, actionLabel].forEach { label in
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

    private func render(snapshot: AuthLinkingReadinessSnapshot) {
        let presentation = AuthLinkingReadinessPresentation(snapshot: snapshot)

        titleLabel.text = "계정 연결 상태"
        stateLabel.text = presentation.title
        actionLabel.text = presentation.actionTitle ?? "계정 연결 비활성"
    }
}
