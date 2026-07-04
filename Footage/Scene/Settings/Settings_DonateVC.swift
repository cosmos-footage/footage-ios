//
//  Settings_DonateVC.swift
//  footage
//
//  Created by 녘 on 2020/07/06.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import StoreKit

@MainActor
class Settings_DonateVC: UIViewController {
    
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var message: UILabel!
    
    let productIDs = ["co.el.iap.bike", "co.el.iap.coffee", "co.el.iap.rice"]
    private var purchaseTask: Task<Void, Never>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.layer.cornerRadius = 10
    }

    deinit {
        purchaseTask?.cancel()
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func requestPurchase(_ sender: UIButton) {
        guard productIDs.indices.contains(sender.tag), AppStore.canMakePayments else { return }

        switch sender.tag {
        case 0: message.text = "자전거를 대여하는 중입니다"
        case 1: message.text = "커피를 내리는 중입니다"
        case 2: message.text = "따뜻한 밥을 짓는 중입니다"
        default: return
        }

        setPurchaseInProgress(true)
        let productID = productIDs[sender.tag]
        purchaseTask?.cancel()
        purchaseTask = Task { [weak self] in
            do {
                guard let product = try await Product.products(for: [productID]).first else {
                    self?.finishPurchase()
                    return
                }

                let result = try await product.purchase()
                if case .success(let verification) = result,
                   case .verified(let transaction) = verification {
                    await transaction.finish()
                }
            } catch {
                // Keep purchase errors local to the UI; do not collect analytics or send logs.
            }

            self?.finishPurchase()
        }
    }
    
    private func setPurchaseInProgress(_ isInProgress: Bool) {
        progressView.isHidden = !isInProgress
        isInProgress ? indicator.startAnimating() : indicator.stopAnimating()
        for button in buttons {
            button.isUserInteractionEnabled = !isInProgress
        }
    }

    private func finishPurchase() {
        setPurchaseInProgress(false)
    }
}
