//
//  RenewedShellPlaceholderViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import UIKit

final class RenewedShellPlaceholderViewController: UIViewController {
    let shellTab: RenewedShellTab

    init(tab: RenewedShellTab) {
        self.shellTab = tab
        super.init(nibName: nil, bundle: nil)
        title = tab.title
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.text = shellTab.title
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
