//
//  ReportDetailVC.swift
//  footage
//
//  Created by 녘 on 2020/07/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class ReportDetailVC: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var badgeCollectionView: UICollectionView!
    @IBOutlet weak var firstColor: UIImageView!
    @IBOutlet weak var secondColor: UIImageView!
    @IBOutlet weak var thirdColor: UIImageView!
    @IBOutlet weak var fourthColor: UIImageView!
    @IBOutlet weak var fifthColor: UIImageView!
    @IBOutlet weak var firstColorDistance: UILabel!
    @IBOutlet weak var secondColorDistance: UILabel!
    @IBOutlet weak var thirdColorDistance: UILabel!
    @IBOutlet weak var fourthColorDistance: UILabel!
    @IBOutlet weak var fifthColorDistance: UILabel!
    @IBOutlet weak var firstCityName: UILabel!
    @IBOutlet weak var secondCityName: UILabel!
    @IBOutlet weak var thirdCityName: UILabel!
    @IBOutlet weak var firstCityImage: UIImageView!
    
    var whichMonth: String = ""
    var badgeList: [Badge] = []
    var colorRanking: Array<(key: String, value: Double)> = []
    var placeRanking: Array<(key: String, value: Double)> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthLabel.text = whichMonth
        if Int(whichMonth)! >= 10 {
            if let badgeArray = LevelManager.callMonthlyBadge(month: "2020\(whichMonth)") {
                badgeList = badgeArray
            } else { badgeList = [Badge(type: "", imageName: "", detail: "")] }
        } else {
            if let badgeArray = LevelManager.callMonthlyBadge(month: "20200\(whichMonth)") {
                badgeList = badgeArray
            } else { badgeList = [Badge(type: "", imageName: "", detail: "")] }
        }
        badgeCollectionView.dataSource = self
        badgeCollectionView.delegate = self
        badgeCollectionView.register(ReportBadgeCell.self, forCellWithReuseIdentifier: ReportBadgeCell.reuseIdentifier)
        badgeCollectionView.backgroundColor = .clear
        badgeCollectionView.allowsSelection = true
        badgeCollectionView.decelerationRate = .fast
        badgeCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        badgeCollectionView.alwaysBounceHorizontal = true
        badgeCollectionView.bounces = true
        badgeCollectionView.contentInset = UIEdgeInsets(top: 0, left: CGFloat(CGFloat(badgeList.count) * ReportBadgeCell().bounds.width), bottom: 0, right: CGFloat(CGFloat(badgeList.count) * ReportBadgeCell().bounds.width))
        setDefaultData()
        loadColorData()
        loadPlaceData()
    }
    
    func loadColorData() {
        
        let imageList = [firstColor, secondColor, thirdColor, fourthColor, fifthColor]
        var colorList: Set = ["#EADE4Cff", "#F0E7CFff", "#F5A997ff", "#FF6B39ff", "#206491ff"]
        
        if colorRanking.count > 0 {
            firstColor.image = UIImage(named: colorRanking[0].key + "Big")
            firstColorDistance.text = String(format: "%.f", (colorRanking[0].value) / 1000) + "km"
            colorList.remove(colorRanking[0].key)
        }
        if colorRanking.count > 1 {
            secondColor.image = UIImage(named: colorRanking[1].key)
            secondColorDistance.text = String(format: "%.f", (colorRanking[1].value) / 1000) + "km"
            colorList.remove(colorRanking[1].key)
        }
        if colorRanking.count > 2 {
            thirdColor.image = UIImage(named: colorRanking[2].key)
            thirdColorDistance.text = String(format: "%.f", (colorRanking[2].value) / 1000) + "km"
            colorList.remove(colorRanking[2].key)
        }
        if colorRanking.count > 3 {
            fourthColor.image = UIImage(named: colorRanking[3].key)
            fourthColorDistance.text = String(format: "%.f", (colorRanking[3].value) / 1000) + "km"
            colorList.remove(colorRanking[3].key)
        }
        if colorRanking.count > 4 {
            fifthColor.image = UIImage(named: colorRanking[4].key)
            fifthColorDistance.text = String(format: "%.f", (colorRanking[4].value) / 1000) + "km"
            colorList.remove(colorRanking[4].key)
        }
        for index in 0..<colorList.count {
            if (4 - index) == 0 {
                imageList[4 - index]!.image = UIImage(named: colorList.removeFirst() + "Big")
            } else {
                imageList[4 - index]!.image = UIImage(named: colorList.removeFirst())
            }
        }
    }
    
    func loadPlaceData() {
        if placeRanking.count > 0 {
            firstCityImage.image = getCityImage(name: placeRanking[0].key.components(separatedBy: " / ").first!)
            firstCityName.text = placeRanking[0].key // "서울특별시 / 동작구"
        }
        if placeRanking.count > 1 {
            secondCityName.text = placeRanking[1].key // "서울특별시 / 동작구"
        }
        if placeRanking.count > 2 {
            thirdCityName.text = placeRanking[2].key // "서울특별시 / 동작구"
        }
    }
    
    func getCityImage(name: String) -> UIImage? {
        switch name {
        case "서울특별시", "Seoul":
            return UIImage(named: "Seoul")
        case "세종특별자치시", "Sejong City":
            return UIImage(named: "Sejong City")
        case "제주도", "Jeju":
            return UIImage(named: "Jeju")
        case "경기도", "Gyeonggi-do":
            return UIImage(named: "Gyeonggi-do")
        case "대전광역시", "Daejeon":
            return UIImage(named: "Daejeon")
        case "울산광역시", "Ulsan":
            return UIImage(named: "Ulsan")
        case "광주광역시", "Gwangju":
            return UIImage(named: "Gwangju")
        case "부산광역시", "Busan":
            return UIImage(named: "Busan")
        case "대구광역시", "Daegu":
            return UIImage(named: "Daegu")
        case "강원도", "Gangwon":
            return UIImage(named: "Gangwon")
        case "인천광역시", "Incheon":
            return UIImage(named: "Incheon")
        case "충청북도", "North Chungcheong":
            return UIImage(named: "North Chungcheong")
        case "경상북도", "North Gyeongsang":
            return UIImage(named: "North Gyeongsang")
        case "전라북도", "North Jeolla":
            return UIImage(named: "North Jeolla")
        case "충청남도", "South Chungcheong":
            return UIImage(named: "South Chungcheong")
        case "경상남도", "South Gyeongsang":
            return UIImage(named: "South Gyeongsang")
        case "전라남도", "South Jeolla":
            return UIImage(named: "South Jeolla")
        default:
            return UIImage(named: "noDataImage")
        }
        
    }
    
    func setDefaultData() {
        firstCityName.text = "-"
        secondCityName.text = "-"
        thirdCityName.text = "-"
        firstCityImage.image = UIImage(named: "noDataImage")
        firstColorDistance.text = "- km"
        secondColorDistance.text = "- km"
        thirdColorDistance.text = "- km"
        fourthColorDistance.text = "- km"
        fifthColorDistance.text = "- km"
    }
    
    
}


extension ReportDetailVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        badgeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reportBadge-cell-reuse-identifier",for: indexPath) as! ReportBadgeCell
        cell.backgroundColor = .clear
        cell.badgeImageView.image = UIImage(named: badgeList[indexPath.row].imageName)
        return cell
    }
    
}

class ReportBadgeCell: UICollectionViewCell {
    
    static let reuseIdentifier = "reportBadge-cell-reuse-identifier"
    
    var badgeImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        badgeImageView.frame = contentView.frame
        contentView.addSubview(badgeImageView)
        Timer.scheduledTimer(withTimeInterval: 0.55, repeats: false) { (_) in self.badgeImageView.alpha = 1}
    }

    required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
}

extension ReportDetailVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
