//
//  RenewedContactMailPresenter.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import MessageUI
import UIKit

protocol ContactMailPresenting {
    @discardableResult
    func presentContactMail(from viewController: UIViewController) -> Bool
}

final class RenewedContactMailPresenter: NSObject, ContactMailPresenting {
    private let recipients: [String]
    private let messageBody: String

    init(
        recipients: [String] = ["el.co.footage@gmail.com"],
        messageBody: String = ""
    ) {
        self.recipients = recipients
        self.messageBody = messageBody
        super.init()
    }

    @discardableResult
    func presentContactMail(from viewController: UIViewController) -> Bool {
        guard MFMailComposeViewController.canSendMail() else {
            return false
        }

        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients(recipients)
        mail.setMessageBody(messageBody, isHTML: true)
        viewController.present(mail, animated: true)
        return true
    }
}

extension RenewedContactMailPresenter: MFMailComposeViewControllerDelegate {
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
}
