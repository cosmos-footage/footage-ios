//
//  LevelVC.swift
//  footage
//
//  Created by 녘 on 2020/06/30.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class LevelVC: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    var badgeList: [Badge] = []
    let screenWidth = UIScreen.main.bounds.width
    var todayBadge: Badge! = nil
    var statsVC: StatsViewController! = nil
    var isTest = true
    var badgeRepository: BadgeRepository = RealmBadgeRepository()

    @IBOutlet weak var badgeDetail: UILabel!
    @IBOutlet weak var todayBadgeImageView: UIImageView!
    @IBAction func goBackButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        statsVC.currentBadge.image = UIImage(named: UserDefaults.standard.string(forKey: "todayBadge") ?? "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let todayBadgeImageName = UserDefaults.standard.string(forKey: "todayBadge") {
            if let todayBadge = badgeRepository.badge(imageName: todayBadgeImageName) {
                self.todayBadge = todayBadge
                todayBadgeImageView.image =  UIImage(named: todayBadgeImageName)
                badgeDetail.text = "\"\(todayBadge.detail)\""
            }
        } else {
            todayBadgeImageView.image = UIImage(named: "")
            badgeDetail.text = ""
        }
        let badgeArray = badgeRepository.badges()
        if !badgeArray.isEmpty {
            badgeList = badgeArray
        } else { badgeList = [Badge(type: "", imageName: "", detail: "")] }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(BadgeCell.self, forCellWithReuseIdentifier: BadgeCell.reuseIdentifier)
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.decelerationRate = .fast
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: true)
        collectionView.alwaysBounceHorizontal = true
        collectionView.bounces = true
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat(CGFloat(badgeList.count) * BadgeCell().bounds.width))
        badgeAnimation()
    }
    
    func badgeAnimation() {
        UIView.animate(withDuration: 0.3) {
            self.todayBadgeImageView.frame.origin.y -= 5
        }
        Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { (timer) in
            UIView.animate(withDuration: 1.2) {
                self.todayBadgeImageView.frame.origin.y += 10
            }
            UIView.animate(withDuration: 0.6) {
                self.todayBadgeImageView.frame.origin.y -= 10
            }
        }
    }
}

extension LevelVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return badgeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "badge-cell-reuse-identifier",for: indexPath) as! BadgeCell
        cell.backgroundColor = .clear
        cell.badgeImageView.image = UIImage(named: badgeList[indexPath.row].imageName)
        cell.badgeImageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 0.5
        todayBadgeImageView.image = UIImage(named: badgeList[indexPath.row].imageName)
        badgeDetail.text = "\"\(badgeList[indexPath.row].detail)\""
        UserDefaults.standard.setValue(badgeList[indexPath.row].imageName, forKey: "todayBadge")
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.contentView.alpha = 1
    }

    
}


class BadgeCell: UICollectionViewCell {
    
    static let reuseIdentifier = "badge-cell-reuse-identifier"
    
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

extension LevelVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
