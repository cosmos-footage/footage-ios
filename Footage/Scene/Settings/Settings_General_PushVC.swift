//
//  Settings_General_PushVC.swift
//  footage
//
//  Created by 녘 on 2020/09/17.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class Settings_General_PushVC: UIViewController {
    
    let cellIdentifier = "generalCell"
    let cellContent = ["일일 알림", "일일 알림 시간", "기타 알림"]
    //    var choicesHour = ["Toyota","Honda","Chevy","Audi","BMW"]
    //    var choicesMinute = ["1","","","",""]
    var pickerView = UIPickerView()
    var typeValue = String()
    var generalVC: Settings_GeneralVC?
    var numberOfRows = 3
    
    @IBOutlet weak var tableView: UITableView!
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setForUpdate()
        tableView.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
}

extension Settings_General_PushVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if indexPath.row == 0 || indexPath.row == 2 {
            let switchView = UISwitch(frame: .zero)
            if indexPath.row == 0 && (UserDefaults.standard.bool(forKey: "everydayPush")){
                switchView.setOn(true, animated: true)
            } else if indexPath.row == 2 && (UserDefaults.standard.bool(forKey: "etcPush")){
                switchView.setOn(true, animated: true)
            } else { switchView.setOn(false, animated: true) }
            switchView.tag = indexPath.row // for detect which row switch Changed
            switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else if indexPath.row == 1 {
            enableTimeSetting(cell: cell, UserDefaults.standard.bool(forKey: "everydayPush"))
        }
        if indexPath.row == 1 {
            let presentation = SettingsPushTimePresentation(
                hour: UserDefaults.standard.integer(forKey: "everydayPushHour"),
                minute: UserDefaults.standard.integer(forKey: "everydayPushMinute")
            )
            cell.textLabel!.text = presentation.settingsRowText(title: cellContent[indexPath.row])
        } else { cell.textLabel!.text = cellContent[indexPath.row] }
        cell.textLabel?.font = UIFont(name: "NanumBarunpen", size: 20)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 1 {
            let alert = UIAlertController(title: "시간 설정", message: "\n\n\n\n\n\n", preferredStyle: .alert)
            
            let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
            
            alert.view.addSubview(pickerFrame)
            pickerFrame.dataSource = self
            pickerFrame.delegate = self
            
            pickerFrame.selectRow(UserDefaults.standard.integer(forKey: "everydayPushHour"), inComponent: 0, animated: true)
            pickerFrame.selectRow(UserDefaults.standard.integer(forKey: "everydayPushMinute"), inComponent: 1, animated: true)
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (UIAlertAction) in
                UserDefaults.standard.set(pickerFrame.selectedRow(inComponent: 0), forKey: "everydayPushHour")
                UserDefaults.standard.set(pickerFrame.selectedRow(inComponent: 1), forKey: "everydayPushMinute")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                Settings_GeneralVC.noti_everyMonthAlert()
                Settings_GeneralVC.noti_everydayAlert()
                self.tableView.reloadData()
                
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        if sender.tag == 0 {
            if sender.isOn {
                let alert = UIAlertController(title: "시간 설정", message: "\n\n\n\n\n\n", preferredStyle: .alert)
                
                let pickerFrame = UIPickerView(frame: CGRect(x: 5, y: 20, width: 250, height: 140))
                
                alert.view.addSubview(pickerFrame)
                pickerFrame.dataSource = self
                pickerFrame.delegate = self
                
                pickerFrame.selectRow(UserDefaults.standard.integer(forKey: "everydayPushHour"), inComponent: 0, animated: true)
                pickerFrame.selectRow(UserDefaults.standard.integer(forKey: "everydayPushMinute"), inComponent: 1, animated: true)
                
                alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (UIAlertAction) in
                    if let cellObj =  self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                        let switchView = cellObj.accessoryView as! UISwitch
                        switchView.setOn(false, animated: true)                }
                }))
                alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (UIAlertAction) in
                    UserDefaults.standard.set(true, forKey: "everydayPush")
                    UserDefaults.standard.set(pickerFrame.selectedRow(inComponent: 0), forKey: "everydayPushHour")
                    UserDefaults.standard.set(pickerFrame.selectedRow(inComponent: 1), forKey: "everydayPushMinute")
                    if let cellObj =  self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
                        self.enableTimeSetting(cell: cellObj, true)
                    }
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    Settings_GeneralVC.noti_everydayAlert()
                    Settings_GeneralVC.noti_everyMonthAlert()
                    self.tableView.reloadData()
                }))
                self.present(alert, animated: true, completion: nil)
            } else if !sender.isOn {
                if let cellObj =  self.tableView.cellForRow(at: IndexPath(row: 1, section: 0)) {
                    self.enableTimeSetting(cell: cellObj, false)
                }
                UserDefaults.standard.set(false, forKey: "everydayPush")
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }
        } else if sender.tag == 2 {
            if sender.isOn {
                UserDefaults.standard.set(true, forKey: "etcPush")
            } else if !sender.isOn {
                UserDefaults.standard.set(false, forKey: "etcPush")
            }
        }
    }
    
    func setForUpdate() {
        if UserDefaults.standard.object(forKey: "wantPush") != nil {
            if UserDefaults.standard.bool(forKey: "wantPush") {
                UserDefaults.standard.set(true, forKey: "everydayPush")
                UserDefaults.standard.set(true, forKey: "etcPush")
            } else {
                UserDefaults.standard.set(false, forKey: "everydayPush")
                UserDefaults.standard.set(false, forKey: "etcPush")
            }
        }
    }
    
    func enableTimeSetting(cell: UITableViewCell, _ on: Bool) {
        cell.accessoryType = on ? .disclosureIndicator : .none
        cell.isUserInteractionEnabled = on
        cell.alpha = on ? 1 : 0.4
    }
}

extension Settings_General_PushVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 24
        } else { return 60 }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        SettingsPushTimePresentation.pickerRowText(row)
    }
    
}
