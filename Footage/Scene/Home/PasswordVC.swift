//
//  PasswordVC.swift
//  footage
//
//  Created by 녘 on 2020/07/26.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import LocalAuthentication
import UIKit

class PasswordVC: UIViewController {
    
    var numberTogether: String = ""
    var userPassword: String = ""
    
    @IBOutlet weak var firstDot: UIImageView!
    @IBOutlet weak var secondDot: UIImageView!
    @IBOutlet weak var thirdDot: UIImageView!
    @IBOutlet weak var fourthDot: UIImageView!
    
    @IBAction func eraseButton(_ sender: Any) {
        if !numberTogether.isEmpty { numberTogether.removeLast() }
        fillDots()
    }
    @IBAction func number1Pressed(_ sender: Any) {
        numberTogether.append("1")
        fillDots()
    }
    @IBAction func number2Pressed(_ sender: Any) {
        numberTogether.append("2")
        fillDots()
    }
    @IBAction func number3Pressed(_ sender: Any) {
        numberTogether.append("3")
        fillDots()
    }
    @IBAction func number4Pressed(_ sender: Any) {
        numberTogether.append("4")
        fillDots()
    }
    @IBAction func number5Pressed(_ sender: Any) {
        numberTogether.append("5")
        fillDots()
    }
    @IBAction func number6Pressed(_ sender: Any) {
        numberTogether.append("6")
        fillDots()
    }
    @IBAction func number7Pressed(_ sender: Any) {
        numberTogether.append("7")
        fillDots()
    }
    @IBAction func number8Pressed(_ sender: Any) {
        numberTogether.append("8")
        fillDots()
    }
    @IBAction func number9Pressed(_ sender: Any) {
        numberTogether.append("9")
        fillDots()
    }
    @IBAction func number0Pressed(_ sender: Any) {
        numberTogether.append("0")
        fillDots()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPassword = UserDefaults.standard.string(forKey: "Password")!
        let userState = UserDefaults.standard.string(forKey: "UserState")
        print("userState is \(String(describing: userState))")
        if userState == "hasBioId" {
            print("Yes You are here")
            authenticateUser()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillDots() {
        switch numberTogether.count {
        case 0:
            firstDot.image = UIImage(systemName: "circle")
            secondDot.image = UIImage(systemName: "circle")
            thirdDot.image = UIImage(systemName: "circle")
            fourthDot.image = UIImage(systemName: "circle")
        case 1:
            firstDot.image = UIImage(systemName: "circle.fill")
            secondDot.image = UIImage(systemName: "circle")
            thirdDot.image = UIImage(systemName: "circle")
            fourthDot.image = UIImage(systemName: "circle")
        case 2:
            firstDot.image = UIImage(systemName: "circle.fill")
            secondDot.image = UIImage(systemName: "circle.fill")
            thirdDot.image = UIImage(systemName: "circle")
            fourthDot.image = UIImage(systemName: "circle")
        case 3:
            firstDot.image = UIImage(systemName: "circle.fill")
            secondDot.image = UIImage(systemName: "circle.fill")
            thirdDot.image = UIImage(systemName: "circle.fill")
            fourthDot.image = UIImage(systemName: "circle")
        case 4:
            firstDot.image = UIImage(systemName: "circle.fill")
            secondDot.image = UIImage(systemName: "circle.fill")
            thirdDot.image = UIImage(systemName: "circle.fill")
            fourthDot.image = UIImage(systemName: "circle.fill")
            
            if checkPassword(writtenPassword: numberTogether) {
                self.dismiss(animated: false, completion: nil)
            } else {
                numberTogether = ""
                fillDots()
            }
            
        default :
            firstDot.image = UIImage(named:
                "circle")
            secondDot.image = UIImage(named:
                "circle")
            thirdDot.image = UIImage(named:
                "circle")
            fourthDot.image = UIImage(named:
                "circle")
            
        }
    }
    
    func checkPassword(writtenPassword: String) -> Bool {
        if writtenPassword == userPassword { return true }
        else { return false }
    }
    
}

extension PasswordVC {
    
    func authenticateUser() {
        let laContext = LAContext()
            var error: NSError?
            let biometricsPolicy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
            if (laContext.canEvaluatePolicy(biometricsPolicy, error: &error)) {
                if let laError = error {
                    print("laError - \(laError)")
                    return
                }
                var localizedReason = "Unlock device"
                if #available(iOS 11.0, *) {
                    switch laContext.biometryType {
                    case .faceID: localizedReason = "Unlock using Face ID"; print("FaceId support")
                    case .touchID: localizedReason = "Unlock using Touch ID"; print("TouchId support")
                    case .opticID: localizedReason = "Unlock using Optic ID"; print("OpticId support")
                    case .none: print("No Biometric support")
                    @unknown default:
                        fatalError()
                    }
                } else {
                    // Fallback on earlier versions
                }
                laContext.evaluatePolicy(biometricsPolicy, localizedReason: localizedReason, reply: { (isSuccess, error) in
                    DispatchQueue.main.async(execute: {
                        if let laError = error {
                            print("laError - \(laError)")
                        } else {
                            if isSuccess { print("sucess")
                                self.dismiss(animated: false, completion: nil)
                            }
                            else { print("failure") }
                        }
                    })
                })
            }
    }
}
