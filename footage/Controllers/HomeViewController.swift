//
//  ViewController.swift
//  footage
//
//  Created by 녘 on 2020/06/09.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit
import EFCountingLabel

class HomeViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    var locationArray: [CLLocation] = []
    var journeyData: JourneyData? = nil
    static var distanceToday: Double = 0
    var timer: Timer?
    
    @IBOutlet weak var mainMap: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var youString: UILabel!
    @IBOutlet weak var todayString: UILabel!
    @IBOutlet weak var footString: UILabel!
    @IBOutlet weak var triangle1: UIImageView!
    @IBOutlet weak var triangle2: UIImageView!
    @IBOutlet weak var triangle3: UIImageView!
    @IBOutlet weak var triangle4: UIImageView!
    @IBOutlet weak var triangle5: UIImageView!
    @IBOutlet weak var square1: UIImageView!
    @IBOutlet weak var square2: UIImageView!
    @IBOutlet weak var square3: UIImageView!
    @IBOutlet weak var square4: UIImageView!
    @IBOutlet weak var distance: EFCountingLabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var unitLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMap.delegate = self
        locationManager.delegate = self
        
        startButton.setImage(#imageLiteral(resourceName: "start_btn"), for: .normal)
        setInitialAlpha()
        setInitialPositionTriangle()
        HomeAnimation.homeStopAnimation(self)
        
        configureInitialMapView()
    }
    
    func setInitialAlpha() {
        startButton.alpha = 0
        square1.alpha = 0
        square2.alpha = 0
        square3.alpha = 0
        square4.alpha = 0
        triangle1.alpha = 0
        triangle2.alpha = 0
        triangle3.alpha = 0
        triangle4.alpha = 0
        triangle5.alpha = 0
        distanceView.alpha = 0
        unitLabel.alpha = 0
    }
    
    func setInitialPositionTriangle() {
        triangle1.frame.origin.y = -40
        triangle2.frame.origin.y = -40
        triangle3.frame.origin.y = -40
        triangle4.frame.origin.y = -40
        triangle5.frame.origin.y = -40
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
        if startButton.currentImage == #imageLiteral(resourceName: "start_btn") { // FROM START TO STOP
            HomeAnimation.homeStartAnimation(self)
            
            locationManager.requestWhenInUseAuthorization()
            for _ in 1...10 { // wait for accurate location
                self.locationManager.requestLocation()
            }
            trackMapView()
            
        } else { // FROM STOP TO START
            StatsViewController.journeyArray.append(journeyData!) // Save journey data
            timer!.invalidate()
            HomeAnimation.homeStopAnimation(self)
            locationArray = []
            // locationManager.pausesLocationUpdatesAutomatically = true
            configureInitialMapView()
        }
    }
    
}

// MARK: Map Kit View

extension HomeViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    func configureInitialMapView() {
        mainMap.mapType = MKMapType.satelliteFlyover
        let coordinateLocation = CLLocationCoordinate2DMake(CLLocationDegrees(exactly: 37.3341)!, CLLocationDegrees(exactly:-122.0092)!)
        let spanValue = MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
        let locationRegion = MKCoordinateRegion(center: coordinateLocation, span: spanValue)
        mainMap.setRegion(locationRegion, animated: true)
        UIView.animate(withDuration: 1) {
            self.mainMap.alpha = 1
        }
    }
    
    func trackMapView() {

        journeyData = JourneyData() // create new data collection template
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.locationManager.requestLocation()
        }
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
//            self.locationManager.requestLocation()
//        }
        while locationManager.location == nil {
            self.locationManager.requestLocation()
        }
        locationArray.append(locationManager.location!) // first item goes into the array
        locationManager.distanceFilter = 5 // meters
        locationManager.pausesLocationUpdatesAutomatically = true
        
        mainMap.mapType = MKMapType.standard
        mainMap.showsUserLocation = true
        myLocation(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, delta: 0.001)
        
        UIView.animate(withDuration: 1) {
            self.mainMap.alpha = 1
        }
    }
 
    func myLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees, delta: Double){
        let coordinateLocation = CLLocationCoordinate2DMake(latitude, longitude)
        let spanValue = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let locationRegion = MKCoordinateRegion(center: coordinateLocation, span: spanValue)
        mainMap.setRegion(locationRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("update called")
        guard let lastLocation = locations.last
            else { return }
        locationArray.append(lastLocation)
        journeyData!.coordinateArray.append(lastLocation.coordinate)
        appendNewDirection()
        myLocation(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude, delta: 0.001)
    }
    
    func appendNewDirection() {
        
        let lastLocation = locationArray[locationArray.count - 2]
        let newLocation = locationArray[locationArray.count - 1]
        HomeViewController.distanceToday += newLocation.distance(from: lastLocation)
        self.distance.text = String(format: "%.2f", HomeViewController.distanceToday / 1000)
        // TODO: 이거 실행되기 전에 distance traveled alpha 1 로 animate되면 이상한 숫자 먼저 뜸
        
        let timeInterval = locationArray[locationArray.count - 1]
            .timestamp.timeIntervalSince(locationArray[locationArray.count - 2].timestamp)
        let distanceInterval = newLocation.distance(from: lastLocation)
        
        if distanceInterval/timeInterval < 8 { // Speed limit
            let newLine = MKPolyline(coordinates: [lastLocation.coordinate, newLocation.coordinate], count: 2)
            self.mainMap.addOverlay(newLine)
        } else {
            return
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineView = MKPolylineRenderer(overlay: overlay)
        polylineView.strokeColor = UIColor(named: "mainColor")
        polylineView.lineWidth = 10
        return polylineView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


