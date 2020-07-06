//
//  JourneyViewController.swift
//  footage
//
//  Created by Wootae on 6/15/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit
import EFCountingLabel
import RealmSwift

class JourneyViewController: UIViewController {
    
    @IBOutlet weak var mainMap: MKMapView!
    @IBOutlet weak var yearLabel: EFCountingLabel!
    @IBOutlet weak var monthLabel: EFCountingLabel!
    @IBOutlet weak var dayLabel: EFCountingLabel!
    @IBOutlet weak var yearText: UILabel!
    @IBOutlet weak var monthText: UILabel!
    @IBOutlet weak var dayText: UILabel!
    @IBOutlet weak var youText: UILabel!
    @IBOutlet weak var seeBackText: UILabel!
    
    var journey: Journey! = nil // comes from previous VC (Stats)
    var journeyIndex = 0 // comes from previous VC (Stats)
    var forReloadStatsVC = DateViewController()
    var photoVC: PhotoCollectionVC! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        mainMap.delegate = self
        configureMap()
        setInitialAlpha()
        JourneyAnimation(journeyVC: self, journeyIndex: journeyIndex).journeyActivate()
        photoVC = PhotoCollectionVC(date: journey.date)
        addChild(photoVC)
        view.addSubview(photoVC.collectionView)
    }
    
    override func viewDidAppear(_ animated: Bool) { // create preview image using screenshot
        let realm = try! Realm()
        let imageData = takeScreenshot().pngData()!
        DateViewController.journeys[journeyIndex].preview = imageData
        do {
            try realm.write {
                let object = DateViewController.journeys[journeyIndex].reference
                if let day = object as? DayData {
                    day.preview = imageData
                } else if let month = object as? Month {
                    month.preview = imageData
                } else if let year = object as? Year {
                    year.preview = imageData
                }
            }
        } catch { print(error)}
        forReloadStatsVC.collectionView.reloadData()
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPhotoSelection", sender: self)
    }
}

// MARK: -Maps

extension JourneyViewController: MKMapViewDelegate {
    
    func configureMap() {
        DrawOnMap.setCamera(journey.footsteps, on: mainMap)
        DrawOnMap.polylineFromFootsteps(journey.footsteps, on: mainMap)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayWithColor = overlay as! PolylineWithColor
        let polylineView = MKPolylineRenderer(overlay: overlay)
        polylineView.strokeColor = overlayWithColor.color
        polylineView.lineWidth = 10
        return polylineView
    }
    
    func calculateAdjustments(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> (CLLocationDirection, Double, Double) { // TODO: 수학 너무 많아... 나중에 할래
        let opposite = to.longitude.distance(to: from.longitude)
        let adjacent = to.latitude.distance(to: from.latitude)
        let degree = atan(opposite / adjacent)
        return (CLLocationDirection(degree * 180 / Double.pi - 90), 0.0005 * cos(degree), 0.0005 * sin(degree))
    }
}

// MARK:- Others

extension JourneyViewController {
    
    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(mainMap.bounds.size, false, UIScreen.main.scale)
        mainMap.drawHierarchy(in: mainMap.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if (image != nil)
        { return image! }
        return UIImage()
    }
    
    func setInitialAlpha() {
        yearLabel.alpha = 0
        monthLabel.alpha = 0
        dayLabel.alpha = 0
        youText.alpha = 0
        seeBackText.alpha = 0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! PhotoSelectionVC
        destinationVC.dateFrom = DateConverter.stringToDate(int: journey.date, start: true) as NSDate
        destinationVC.dateTo = DateConverter.stringToDate(int: journey.date, start: false) as NSDate
        destinationVC.photoCollectionVC = photoVC
    }
}

class PolylineWithColor: MKPolyline {
    var color: UIColor = .white
}

