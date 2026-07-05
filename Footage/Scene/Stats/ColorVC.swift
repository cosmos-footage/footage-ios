//
//  ColorVC.swift
//  footage
//
//  Created by 녘 on 2020/06/30.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import EFCountingLabel

class ColorVC: UIViewController {
    
    @IBOutlet weak var firstColor: UIImageView!
    @IBOutlet weak var secondColor: UIImageView!
    @IBOutlet weak var thirdColor: UIImageView!
    @IBOutlet weak var fourthColor: UIImageView!
    @IBOutlet weak var fifthColor: UIImageView!
    @IBOutlet weak var firstColorDistance: EFCountingLabel!
    @IBOutlet weak var secondColorDistance: EFCountingLabel!
    @IBOutlet weak var thirdColorDistance: EFCountingLabel!
    @IBOutlet weak var fourthColorDistance: EFCountingLabel!
    @IBOutlet weak var fifthColorDistance: EFCountingLabel!
    
    var ranking: Array<(key: String, value: Double)> = []
    
    override func viewDidLoad() {
        setDefaultData()
        loadData()
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func colorPressed(_ sender: UIButton) {
        if sender.tag < ranking.count {
            performSegue(withIdentifier: "goToColoredJourney", sender: sender)
        }
    }
    @IBAction func alertTest(_ sender: UIButton) {
        BadgeGiver.gotBadge(view: view, badge: Badge(type: "distance", imageName: "total_1000", detail: "1000km. 더이상 거리 재는건 무의미하네요. 그저 당신이 추억한, 추억할 발걸음이 아름다울 뿐입니다."))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let button = sender as! UIButton
        let destinationVC = segue.destination as! ColoredJourneyVC
        destinationVC.color = ranking[button.tag].key
    }
    
    
    func loadData() {
        
        let imageList = [firstColor, secondColor, thirdColor, fourthColor, fifthColor]
        var colorList: Set = ["#EADE4Cff", "#F0E7CFff", "#F5A997ff", "#FF6B39ff", "#206491ff"]
        
        if ranking.count > 0 {
            firstColor.image = UIImage(named: ranking[0].key)
            firstColorDistance.text = DistanceTextPresentation(meters: ranking[0].value, style: .decimal2).text
            colorList.remove(ranking[0].key)
        }
        if ranking.count > 1 {
            secondColor.image = UIImage(named: ranking[1].key)
            secondColorDistance.text = DistanceTextPresentation(meters: ranking[1].value, style: .decimal2).text
            colorList.remove(ranking[1].key)
        }
        if ranking.count > 2 {
            thirdColor.image = UIImage(named: ranking[2].key)
            thirdColorDistance.text = DistanceTextPresentation(meters: ranking[2].value, style: .decimal2).text
            colorList.remove(ranking[2].key)
        }
        if ranking.count > 3 {
            fourthColor.image = UIImage(named: ranking[3].key)
            fourthColorDistance.text = DistanceTextPresentation(meters: ranking[3].value, style: .decimal2).text
            colorList.remove(ranking[3].key)
        }
        if ranking.count > 4 {
            fifthColor.image = UIImage(named: ranking[4].key)
            fifthColorDistance.text = DistanceTextPresentation(meters: ranking[4].value, style: .decimal2).text
            colorList.remove(ranking[4].key)
        }
        for index in 0..<colorList.count {
            imageList[4 - index]!.image = UIImage(named: colorList.removeFirst())
        }
    }
    
    func setDefaultData() {
        firstColorDistance.text = "-\t"
        secondColorDistance.text = "-\t"
        thirdColorDistance.text = "-\t"
        fourthColorDistance.text = "-\t"
        fifthColorDistance.text = "-\t"
    }
}
