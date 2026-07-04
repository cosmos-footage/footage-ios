//
//  Settings_GeneralVC.swift
//  footage
//
//  Created by 녘 on 2020/07/06.
//  Copyright © 2020 DreamPizza. All rights reserved.
//
import UIKit

class Settings_GeneralVC: UIViewController {
    
    let cellIdentifier = "generalCell"
    let cloudBackupCellIdentifier = "cloudBackupCell"
    let cellContent = ["내 정보","알림 설정", "암호잠금", "FaceID 및 TouchID", "클라우드 백업"]
    var cloudBackupSettingsStore = CloudBackupSettingsStore()
    let manualBackupRunner = AppCompositionRoot().makeManualCloudBackupRunner()
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPasswordSettings" {
            let destinationVC = segue.destination as! Settings_General_PasswordVC
            destinationVC.generalVC = self
            if let sender = sender as? UISwitch {
                if sender.tag == 2 {
                    destinationVC.whereAreYouFrom = "passcode"
                } else if sender.tag == 3 {
                    destinationVC.whereAreYouFrom = "faceId"
                }
            }
        }
    }
}

extension Settings_GeneralVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 4 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cloudBackupCellIdentifier)
            let switchView = UISwitch(frame: .zero)
            switchView.setOn(cloudBackupSettingsStore.isOptedIn, animated: false)
            switchView.tag = indexPath.row
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
            cell.textLabel?.text = cellContent[indexPath.row]
            cell.textLabel?.font = UIFont(name: "NanumBarunpen", size: 20)
            cell.detailTextLabel?.text = cloudBackupStatusText()
            cell.detailTextLabel?.font = UIFont(name: "NanumBarunpen", size: 13)
            cell.detailTextLabel?.textColor = .gray
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if indexPath.row == 0 || indexPath.row == 1 {
            cell.accessoryType = .disclosureIndicator; cell.selectionStyle = .default
        } else {
            let switchView = UISwitch(frame: .zero)
            if indexPath.row == 2 && (UserDefaults.standard.string(forKey: "UserState") == "hasPassword" || UserDefaults.standard.string(forKey: "UserState") == "hasBioId") {
                switchView.setOn(true, animated: true)
            } else if indexPath.row == 3 && UserDefaults.standard.string(forKey: "UserState") == "hasBioId" {
                switchView.setOn(true, animated: true)
            } else { switchView.setOn(false, animated: true) }
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        }
        
        cell.textLabel!.text = cellContent[indexPath.row]
        cell.textLabel?.font = UIFont(name: "NanumBarunpen", size: 20)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            performSegue(withIdentifier: "goToGeneralProfileSettings", sender: self)
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: "goToGeneralPushSettings", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        
        if sender.tag == 2 {
            if sender.isOn { // remove password
                performSegue(withIdentifier: "goToPasswordSettings", sender: sender)
            } else if !sender.isOn {
                let youSureAlert = UIAlertController.init(title: "주의", message: "정말 비밀번호를 삭제하시겠습니까?", preferredStyle:  .alert)
                let realOk =  UIAlertAction.init(title: "삭제", style: .default) { (action) in
                    if let cellObj =  self.tableView.cellForRow(at: IndexPath(row: sender.tag+1, section: 0)) {
                        let switchView = cellObj.accessoryView as! UISwitch
                        switchView.setOn(false, animated: true)
                    }
                    UserDefaults.standard.setValue("noPassword", forKey: "UserState")
                }
                let actuallyNo = UIAlertAction.init(title: "취소", style: .cancel) { (action) in
                    if let cellObj =  self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) {
                        let switchView = cellObj.accessoryView as! UISwitch
                        switchView.setOn(true, animated: true)
                    }
                }
                youSureAlert.addAction(realOk)
                youSureAlert.addAction(actuallyNo)
                
                self.present(youSureAlert, animated: true, completion: nil)
            }
        }
        
        if sender.tag == 3 {
            if sender.isOn { // turn on bio id
                if let cellObj =  self.tableView.cellForRow(at: IndexPath(row: sender.tag-1, section: 0)) {
                    let switchView = cellObj.accessoryView as! UISwitch
                    if switchView.isOn {
                        UserDefaults.standard.setValue("hasBioId", forKey: "UserState")
                    }
                    else if !switchView.isOn {
                        switchView.setOn(true, animated: true)
                        performSegue(withIdentifier: "goToPasswordSettings", sender: sender)
                    }
                }
                
            } else if !sender.isOn { // turn on password
                UserDefaults.standard.setValue("hasPassword", forKey: "UserState")
            }
            
        }

        if sender.tag == 4 {
            cloudBackupSettingsStore.isOptedIn = sender.isOn
            tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .none)
        }
        
//        if sender.tag == 3 {
//            if sender.isOn {
//                Settings_GeneralVC.registerNoti()
//                Settings_GeneralVC.noti_everydayAlert()
//                UserDefaults.standard.setValue(true, forKey: "wantPush")
//            } else if !sender.isOn {
//                let center = UNUserNotificationCenter.current()
//                center.removeAllPendingNotificationRequests()
//                UserDefaults.standard.setValue(false, forKey: "wantPush")
//            }
//        }
    }

    private func cloudBackupStatusText() -> String {
        let status = manualBackupRunner.localBackupStatus()
        return "대기 \(status.pendingCount) / 실패 \(status.failedCount)"
    }
    
}

extension Settings_GeneralVC: UNUserNotificationCenterDelegate{
    
    static func registerNoti() {
        UserNotificationSchedulingService().requestAuthorization { granted, error in
            if granted {
                print(granted)
            } else {
                print("Error in get authorization for notification")
            }
        }
    }
    
    static func noti_everydayAlert() {
        UserNotificationSchedulingService().scheduleEverydayAlert { error in
            if error != nil {
                print("something went wrong")
            }
        }
    }
    
    static func noti_everyMonthAlert() {
        UserNotificationSchedulingService().scheduleEveryMonthAlert { error in
            if error != nil {
                print("something went wrong")
            }
        }
    }
    
}
