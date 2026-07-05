//
//  Settings_AboutVC.swift
//  footage
//
//  Created by 녘 on 2020/07/06.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MessageUI

class Settings_AboutVC:UIViewController {
    
    let cellIdentifier = "aboutCell"
    let cellContent = ["개인정보 취급방침","문의하기"]
    
    @IBOutlet weak var versionText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        setVersion()
    }
    
    func setVersion(){
        let version = UserDefaults.standard.integer(forKey: "version")
        versionText.text = AppVersionPresentation(legacyVersionCode: version).text
    }
}

extension Settings_AboutVC: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel!.text = cellContent[indexPath.row]
        cell.textLabel?.font = UIFont(name: "NanumBarunpen", size: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            performSegue(withIdentifier: "goToPersonalInformation", sender: self)
        }
        if indexPath.row == 1 {
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients(["el.co.footage@gmail.com"])
                mail.setMessageBody("", isHTML: true)
                present(mail, animated: true)
            } else {
                print("Cannot send email")
            }
            
        }
    }
    
    
    
}

extension Settings_AboutVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
