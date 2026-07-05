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
    var badgeRepository: BadgeRepository = RealmBadgeRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthLabel.text = whichMonth
        if Int(whichMonth)! >= 10 {
            if let badgeArray = badgeRepository.monthlyBadges(month: "2020\(whichMonth)") {
                badgeList = badgeArray
            } else { badgeList = [Badge(type: "", imageName: "", detail: "")] }
        } else {
            if let badgeArray = badgeRepository.monthlyBadges(month: "20200\(whichMonth)") {
                badgeList = badgeArray
            } else { badgeList = [Badge(type: "", imageName: "", detail: "")] }
        }
        badgeCollectionView.dataSource = self
        badgeCollectionView.delegate = self
        badgeCollectionView.register(ReportBadgeCell.self, forCellWithReuseIdentifier: ReportBadgeCell.reuseIdentifier)
        badgeCollectionView.backgroundColor = .clear
        badgeCollectionView.allowsSelection = true
        badgeCollectionView.decelerationRate = .fast
        badgeCollectionView.alwaysBounceHorizontal = true
        badgeCollectionView.bounces = true
        //badgeCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(badgeList.count) * ReportBadgeCell().bounds.width)
        setDefaultData()
        loadColorData()
        loadPlaceData()
        //badgeCollectionView.contentOffset = CGPoint(x: (K.screenWidth - 80) / -2, y: 0)
        //badgeCollectionView.setContentOffset(CGPoint(x: 100, y: 100), animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if badgeList.count < 4 {
            badgeCollectionView.setContentOffset(CGPoint(x: (K.screenWidth * 0.76 - CGFloat(80 * badgeList.count)) / -2, y: 0), animated: false)
            badgeCollectionView.isScrollEnabled = false
        }
        UIView.animate(withDuration: 0.1) {
            self.badgeCollectionView.alpha = 1
        }
    }
    
    func loadColorData() {
        
        let imageList = [firstColor, secondColor, thirdColor, fourthColor, fifthColor]
        var colorList: Set = ["#EADE4Cff", "#F0E7CFff", "#F5A997ff", "#FF6B39ff", "#206491ff"]
        
        if colorRanking.count > 0 {
            firstColor.image = UIImage(named: colorRanking[0].key + "Big")
            firstColorDistance.text = DistanceTextPresentation(meters: colorRanking[0].value, style: .integerWithKm).text
            colorList.remove(colorRanking[0].key)
        }
        if colorRanking.count > 1 {
            secondColor.image = UIImage(named: colorRanking[1].key)
            secondColorDistance.text = DistanceTextPresentation(meters: colorRanking[1].value, style: .integerWithKm).text
            colorList.remove(colorRanking[1].key)
        }
        if colorRanking.count > 2 {
            thirdColor.image = UIImage(named: colorRanking[2].key)
            thirdColorDistance.text = DistanceTextPresentation(meters: colorRanking[2].value, style: .integerWithKm).text
            colorList.remove(colorRanking[2].key)
        }
        if colorRanking.count > 3 {
            fourthColor.image = UIImage(named: colorRanking[3].key)
            fourthColorDistance.text = DistanceTextPresentation(meters: colorRanking[3].value, style: .integerWithKm).text
            colorList.remove(colorRanking[3].key)
        }
        if colorRanking.count > 4 {
            fifthColor.image = UIImage(named: colorRanking[4].key)
            fifthColorDistance.text = DistanceTextPresentation(meters: colorRanking[4].value, style: .integerWithKm).text
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
        let city = CityPresentation(sourceName: name, fallback: .noData)
        return UIImage(named: city.imageName)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgeList.count
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
