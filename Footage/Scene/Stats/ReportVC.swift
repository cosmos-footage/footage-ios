//
//  Report.swift
//  footage
//
//  Created by 녘 on 2020/07/14.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class ReportVC: UIViewController {
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var januaryButton: UIButton!
    @IBOutlet weak var februaryButton: UIButton!
    @IBOutlet weak var marchButton: UIButton!
    @IBOutlet weak var aprilButton: UIButton!
    @IBOutlet weak var mayButton: UIButton!
    @IBOutlet weak var juneButton: UIButton!
    @IBOutlet weak var julyButton: UIButton!
    @IBOutlet weak var augustButton: UIButton!
    @IBOutlet weak var septemberButton: UIButton!
    @IBOutlet weak var octoberButton: UIButton!
    @IBOutlet weak var novemberButton: UIButton!
    @IBOutlet weak var decemberButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var monthLabel: UILabel!
    
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToReportDetail", sender: sender)
    }
    
    @IBAction func nextMonthButtonPressed(_ sender: Any) {
        thisYear += 1
        monthLabel.text = String(thisYear)
        setButtons()
    }
    @IBAction func prevMonthButtonPressed(_ sender: Any) {
        thisYear -= 1
        monthLabel.text = String(thisYear)
        setButtons()
    }
    
    
    var colorRank: Array<(key: String, value: Double)> = []
    var placeRank: Array<(key: String, value: Double)> = []
    var startDate: Int?
    var endDate: Int?
    var thisYear = 2020
    var colorRepository: ColorRepository = RealmColorRepository()
    var placeRepository: PlaceRepository = RealmPlaceRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        thisYear = Calendar.current.component(.year, from: Date())
        setButtons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ReportDetailVC
        guard let selectedButton = sender as? UIButton else { return }
        setStartEndDate(year: thisYear, tag: selectedButton.tag)
        destinationVC.whichMonth = String(selectedButton.tag)
        destinationVC.colorRanking = colorRepository.rankingDistance(startDate: startDate!, endDate: endDate!)
        destinationVC.placeRanking = placeRepository.rankingDistance(startDate: startDate!, endDate: endDate!)
    }
    
    func setButtons() {
        monthLabel.text = String(thisYear)
        let monthButtonList = [januaryButton, februaryButton, marchButton, aprilButton, mayButton, juneButton, julyButton, augustButton, septemberButton, octoberButton, novemberButton, decemberButton]
        for index in 0...11 {
            setStartEndDate(year: thisYear, tag: (index+1))
            if colorRepository.rankingDistance(startDate: startDate!, endDate: endDate!).isEmpty {
                monthButtonList[index]!.isEnabled = false
                monthButtonList[index]!.alpha = 0.1
            } else {
                monthButtonList[index]!.isEnabled = true
                monthButtonList[index]!.alpha = 1
            }
        }
        setPrevNextButtons()
    }
    
    func setStartEndDate(year: Int, tag: Int) {
        startDate = DateConverter.tagToMonth(year: year, tag: tag, start: true)
        endDate = DateConverter.tagToMonth(year: year, tag: tag, start: false)
    }
    
    func setPrevNextButtons(){
        var prevCnt = 0
        var nextCnt = 0
        for index in 0...11 {
            setStartEndDate(year: thisYear+1, tag: (index+1))
            if !colorRepository.rankingDistance(startDate: startDate!, endDate: endDate!).isEmpty {
                nextCnt+=1
            }
        }
        for index in 0...11 {
            setStartEndDate(year: thisYear-1, tag: (index+1))
            if !colorRepository.rankingDistance(startDate: startDate!, endDate: endDate!).isEmpty {
                prevCnt+=1
            }
        }
        if prevCnt>0 {
            prevButton.isEnabled = true
            prevButton.alpha = 1
        } else {
            prevButton.isEnabled = false
            prevButton.alpha = 0.1
        }
        if nextCnt>0 {
            nextButton.isEnabled = true
            nextButton.alpha = 1
        } else {
            nextButton.isEnabled = false
            nextButton.alpha = 0.1
        }
    }
}
