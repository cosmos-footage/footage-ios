//
//  BotVC.swift
//  footage
//
//  Created by Wootae on 7/28/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit

class MapBottomVC: UIViewController {
    
    let panRecognizer = UIPanGestureRecognizer()
    let backButton = UIButton(frame: CGRect(x: 10, y: 30, width: 40, height: 40))
    
    var journeyButton = UIButton(frame: CGRect(x: K.screenWidth / 2 - 125, y: 510, width: 250, height: 60))
    var resultLabel = UILabel(frame: CGRect(x: 17, y: 145, width: K.screenWidth, height: 15))
    var selectedView = SelectedView()
    var viewState: ViewState = ViewState.small {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.view.frame = CGRect(origin: self.viewState.origin(), size: self.viewState.size())
            }
            M.mapVC.mapView.frame.origin.y -= (viewState.rawValue - oldValue.rawValue) / 2
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view.frame = CGRect(origin: viewState.origin(), size: viewState.size())
        view.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.addSubview(selectedView)
        view.addSubview(M.tableVC.tableView)
        view.addSubview(M.collectionVC.collectionView)
        M.collectionVC.collectionView.isHidden = true
        setupRecognizers() // for moving bottom VC
        setupButtons() // back button for later use; from collection to tableview
        setupResultLabel()
        setupJourneyButton()
    }
    
    func setupResultLabel() {
        resultLabel.font = UIFont(name: "NanumBarunpen-Bold", size: 17)
        resultLabel.backgroundColor = UIColor.clear
        view.addSubview(resultLabel)
    }
    
    func setupJourneyButton() {
        journeyButton.setImage(UIImage(named: "moveToJourneyButton"), for: .normal)
        journeyButton.isHidden = true
        journeyButton.addTarget(self, action: #selector(moveToJourney), for: .touchUpInside)
        view.addSubview(journeyButton)
    }
    
    @objc func moveToJourney() {
        let date = DateConverter.dateToDay(date: selectedView.footstep.timestamp)
        guard let tabBarController = M.mapVC.tabBarController else { return }
        tabBarController.selectedIndex = 3
        if let dateVC = tabBarController.viewControllers![3] as? DateViewController {
            let dateList = DateViewController.journeys.map { $0.date }
            dateVC.performSegue(withIdentifier: "goToJourney", sender: dateList.firstIndex(of: date))
        }
    }
    
    enum ViewState: CGFloat {
        case small = 90
        case medium = 305
        case large = 570
        
        func origin() -> CGPoint {
            return CGPoint(x: 0, y: K.contentHeight - self.rawValue)
        }
        
        func size() -> CGSize {
            return CGSize(width: K.screenWidth, height: K.contentHeight)
        }
    }
    
    func setupRecognizers() {
        panRecognizer.addTarget(self, action: #selector(adjustViewFrame))
        view.addGestureRecognizer(panRecognizer)
        selectedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCollection)))
    }
    
    func setupButtons() {
        backButton.addTarget(self, action: #selector(showTable), for: .touchUpInside)
        backButton.setImage(#imageLiteral(resourceName: "backButton"), for: .normal)
        view.addSubview(backButton)
        backButton.isHidden = true
        let topBar = UIImageView(frame: CGRect(x: K.screenWidth/2 - 30, y: 10, width: 60, height: 15))
        topBar.image = UIImage(systemName: "chevron.compact.up")
        topBar.tintColor = UIColor(hex: "#C0C0C0FF")
        view.addSubview(topBar)
    }
    
    @objc func adjustViewFrame(recognizer: UIPanGestureRecognizer) {
        M.mapVC.preventTableUpdate = true
        let translation = recognizer.translation(in: view)
        let newOrigin = view.frame.origin.y + translation.y
        if newOrigin > 0 {
            view.frame.origin.y = newOrigin
        }
        recognizer.setTranslation(CGPoint.zero, in: view)
        if recognizer.state == .ended { determineFinalState() }
    }
    
    func determineFinalState() { // changing viewState causes frame change by didSet
        let smallMax = (ViewState.small.rawValue + ViewState.medium.rawValue) / 2
        let mediumMax = (ViewState.medium.rawValue + ViewState.large.rawValue) / 2
        switch K.screenHeight - view.frame.origin.y - K.tabBarHeight { // ratio of current height
        case 0..<smallMax: viewState = ViewState.small
        case smallMax..<mediumMax: viewState = ViewState.medium
        default: viewState = ViewState.large }
        M.mapVC.preventTableUpdate = false
    }
    
    func reloadSelectedView(selected footstep: Footstep?) {
        if let footstep = footstep { selectedView.footstepSelected(selectedFootstep: footstep) }
        else { selectedView.showFirstLabel() }
    }
    
    @objc func showCollection() {
        guard let footstep = selectedView.footstep else { return }
        M.collectionVC.reload(with: footstep)
        M.collectionVC.collectionView.isHidden = false
        backButton.isHidden = false
        journeyButton.isHidden = false
        view.bringSubviewToFront(backButton)
        M.tableVC.tableView.isHidden = true
        M.mapVC.preventTableUpdate = true
        resultLabel.isHidden = true
        if viewState == .small { viewState = .medium }
    }
    
    @objc func showTable() {
        M.collectionVC.collectionView.isHidden = true
        backButton.isHidden = true
        journeyButton.isHidden = true
        resultLabel.isHidden = false
        M.tableVC.tableView.isHidden = false
        M.mapVC.preventTableUpdate = false
    }
    
}

class SelectedView: UIView {
    
    var footstep: Footstep! = nil
    var footstepImage = UIImageView(frame: CGRect(x: 10, y: 30, width: 40, height: 40))
    var timeLabel = UILabel(frame: CGRect(x: 60, y: 27, width: 200, height: 30))
    var categoryLabel = UILabel(frame: CGRect(x: 60, y: 47, width: 200, height: 30))
    var photoCountLabel = UILabel(frame: CGRect(x: 250, y: 35, width: 200, height: 30))
    var noteCountLabel = UILabel(frame: CGRect(x: 300, y: 35, width: 200, height: 30))
    var firstLabel = UILabel(frame: CGRect(x: 35, y: 30, width: K.screenWidth - 20, height: 30))
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: K.screenWidth, height: 90))
        configureLabels()
        showFirstLabel()
    }
    
    func showFirstLabel() {
        for subview in subviews { subview.isHidden = true }
        firstLabel.isHidden = false
        backgroundColor = .clear
    }
    
    func footstepSelected(selectedFootstep: Footstep) {
        footstep = selectedFootstep
        let date = DateConverter.dateToDay(date: footstep.timestamp)
        let presentation = MapFootstepPresentation(
            legacyDateKey: date,
            distanceKilometers: 0,
            categoryName: UserDefaults.standard.string(forKey: footstep.color),
            photoCount: footstep.photos.count,
            noteCount: footstep.notes.filter({ $0 != "" }).count
        )
        timeLabel.text = presentation.dateText
        categoryLabel.text = presentation.categoryName
        photoCountLabel.text = presentation.photoCountText
        noteCountLabel.text = presentation.noteCountText
        backgroundColor = UIColor(hex: footstep.color)?.withAlphaComponent(0.9)
        for subview in subviews { subview.isHidden = false }
        firstLabel.isHidden = true
    }
    
    func configureLabels() {
        firstLabel.text = "발자취를 선택해 그 날의 기록을 돌아보세요"
        firstLabel.font = UIFont(name: "NanumBarunpen", size: 20)
        addSubview(firstLabel)
        
        footstepImage.image = #imageLiteral(resourceName: "addFootstep")
        addSubview(footstepImage)
        
        timeLabel.font = UIFont(name: "NanumBarunpen-Bold", size: 20)
        addSubview(timeLabel)
        
        categoryLabel.font = UIFont(name: "NanumBarunpen", size: 15)
        addSubview(categoryLabel)
        
        photoCountLabel.font = UIFont(name: "NanumBarunpen", size: 15)
        addSubview(photoCountLabel)
        
        noteCountLabel.font = UIFont(name: "NanumBarunpen", size: 15)
        addSubview(noteCountLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
