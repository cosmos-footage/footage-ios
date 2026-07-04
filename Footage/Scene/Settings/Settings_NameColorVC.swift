//
//  Settings_NameColorVC.swift
//  footage
//
//  Created by 녘 on 2020/07/06.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class Settings_NameColorVC: UIViewController {
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var fifthLabel: UILabel!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func firstColorEditPressed(_ sender: UIButton) {
        giveAlert(labelname: firstLabel, hexCode: "#EADE4Cff")
    }
    @IBAction func secondColorEditPressed(_ sender: UIButton) {
        giveAlert(labelname: secondLabel, hexCode: "#F5A997ff")
    }
    @IBAction func thirdColorEditPressed(_ sender: UIButton) {
        giveAlert(labelname: thirdLabel, hexCode: "#F0E7CFff")
    }
    @IBAction func fourthColorEditPressed(_ sender: UIButton) {
        giveAlert(labelname: fourthLabel, hexCode: "#FF6B39ff")
    }
    @IBAction func fifthColorEditPressed(_ sender: UIButton) {
        giveAlert(labelname: fifthLabel, hexCode: "#206491ff")
    }
    
    override func viewDidLoad() {
        guard let widgetUD = UserDefaults(suiteName: "group.footage") else { return }
        firstLabel.text = widgetUD.string(forKey: "#EADE4Cff")
        secondLabel.text = widgetUD.string(forKey: "#F5A997ff")
        thirdLabel.text = widgetUD.string(forKey: "#F0E7CFff")
        fourthLabel.text = widgetUD.string(forKey: "#FF6B39ff")
        fifthLabel.text = widgetUD.string(forKey: "#206491ff")
    }
    
    
    func giveAlert(labelname: UILabel, hexCode: String) {
        var userInput: String = ""
        let rename = UIAlertController.init(title: "카테고리 설정", message: "6자 이내로 카테고리 이름을 입력해주세요.", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "수정", style: .default) { (action) in
            userInput = rename.textFields![0].text!
            if (userInput.isEmpty) {
                return
            }
            let youSureAlert = UIAlertController.init(title: "주의!", message: "월간리포트에서는 카테고리의 이름이 아닌 발자취의 색깔에 따라 거리가 합산됩니다.", preferredStyle:  .alert)
            let realOk =  UIAlertAction.init(title: "수정", style: .default) { (action) in
                labelname.text = userInput
                UserDefaults(suiteName: "group.footage")?.set(labelname.text, forKey: hexCode)
            }
            let actuallyNo = UIAlertAction.init(title: "취소", style: .cancel) { (action) in
                print(action)
            }
            youSureAlert.addAction(realOk)
            youSureAlert.addAction(actuallyNo)
            
            
            self.present(youSureAlert, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { (action) in
            print(action)
        }
        rename.addTextField { (textField) in
            textField.placeholder = labelname.text
            textField.smartInsertDeleteType = .no
            textField.delegate = self
        }
        rename.addAction(okAction)
        rename.addAction(cancelAction)
        
        
        self.present(rename, animated: true, completion: nil)
    }
}

extension Settings_NameColorVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
            return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 7
    }
}
