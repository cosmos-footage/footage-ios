//
//  DateViewController.swift
//  footage
//
//  Created by 녘 on 2020/06/09.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit
import EFCountingLabel

class DateViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var profileImage: UIImage = #imageLiteral(resourceName: "baseProfileImage")
    
    @IBOutlet weak var rangeControl: UISegmentedControl!
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    static var journeys: [Journey] = []
    
    var dataSource: UICollectionViewDiffableDataSource<Section, MapCell>! = nil
    var routeRepository: RouteRepository = RealmRouteRepository()
    
    static let badgeElementKind = "badge-element-kind"
    enum Section {
        case main
    }
    
    @IBAction func dateRangeChanged(_ sender: UISegmentedControl) {
        loadWithRange(sender.selectedSegmentIndex)
    }
    @IBAction func recordButtonPressed(_ sender: UIButton) {
        self.tabBarController?.selectedIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        loadWithRange(rangeControl.selectedSegmentIndex)
        reloadProfileImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        reloadProfileImage()
    }
}

extension DateViewController {
    private func createLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(widthDimension:.absolute(147), heightDimension: .absolute(177))
        let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [])
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(315), heightDimension: .estimated(177))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        group.interItemSpacing = .fixed(20)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        let inset = (K.screenWidth - 315) / 2
        section.contentInsets = .init(top: 0, leading: inset, bottom: 0, trailing: inset)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

// MARK: -configure view frame hierarchy

extension DateViewController {
    private func configureHierarchy() {
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "MapCell", bundle: nil), forCellWithReuseIdentifier: MapCell.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.allowsSelection = true
        //collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        view.sendSubviewToBack(collectionView)
    }
}



// MARK: configure view data source

extension DateViewController {
    private func configureDataSource() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM ddd"
        dataSource = UICollectionViewDiffableDataSource<Section, MapCell>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: MapCell) -> UICollectionViewCell? in
            
            // Get a cell of the desired kind.
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MapCell.reuseIdentifier,
                    for: indexPath) as? MapCell else { fatalError("Could not create new cell") }
            
            cell.mapImage.image = UIImage(data: DateViewController.journeys[indexPath.row].preview)
            let date = DateViewController.journeys[indexPath.row].date
            
            switch date {
            case ...10000: cell.label.text = String(date) + "년"
            case 10001...1000000: cell.label.text = String(date / 100) + "년 " + String(date % 100) + "월"
            default:
                cell.label.text =  String(date / 100 % 100) + "월 " + String(date % 100) + "일"
            }
            
            return cell
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, MapCell>()
        var cellArray: [MapCell] = []
        let journeys = DateViewController.journeys
        if !journeys.isEmpty {
            for i in 0...journeys.count - 1 {
                cellArray.append(MapCell())
                cellArray[i].journey = journeys[i]
            }
        } else {
        }
        snapshot.appendSections([.main])
        snapshot.appendItems(cellArray)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension DateViewController {
    
    func reloadProfileImage() {
        if let profileData = UserDefaults.standard.data(forKey: "profileImage") {
            profileImage = UIImage(data: profileData)!
            profileView.image = profileImage
        }
        if let profileID = UserDefaults.standard.string(forKey: "userName") {
            profileName.text = profileID
        }
        profileView.layer.cornerRadius = profileView.bounds.width / 2.0
    }
    
    private func loadWithRange(_ range: Int) {
        DateViewController.journeys = []
        var snapshot = NSDiffableDataSourceSnapshot<Section, MapCell>()
        var cellArray: [MapCell] = []
        let rangeKey: String
        switch range {
        case 0: rangeKey = "day"
        case 1: rangeKey = "month"
        default: rangeKey = "year"
        }
        for journey in routeRepository.loadJourneys(rangeOf: rangeKey) {
            DateViewController.journeys.append(journey)
        }
        
        if !DateViewController.journeys.isEmpty {
            for i in 0...DateViewController.journeys.count - 1 {
                cellArray.append(MapCell())
                cellArray[i].journey = DateViewController.journeys[i]
            }
            view.bringSubviewToFront(collectionView)
        }
        snapshot.appendSections([.main])
        snapshot.appendItems(cellArray)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

extension DateViewController: UICollectionViewDelegate {
    @IBAction func changePressed(_ sender: Any) {
        performSegue(withIdentifier: "goToProfile", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToJourney", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToProfile":
            let destinationVC = segue.destination as! ProfileSelectionVC
            destinationVC.parentVC = self
        case "goToJourney":
            let destinationVC = segue.destination as! JourneyViewController
            destinationVC.journeyManager = JourneyManager(journeyIndex: sender as! Int)
            destinationVC.dateVC = self
        default: break
        }
    }
    
    
}
