//
//  MapViewController.swift
//  footage
//
//  Created by Wootae on 7/28/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MapViewController: UIViewController {
    
    let mapView = MKMapView()
    let locationManager = CLLocationManager()
    
    var overlayOn = true
    var overlayButton = UIButton()
    var preventTableUpdate = false // to prevent table from reloading when collectionview is showing / view is resizing
    var currentLocation = CLLocationCoordinate2D(latitude: 36.4800984, longitude: 127.2802807)
    var footstepsWithAssets: [Footstep] = []
    var allFootsteps: [Footstep] = [] {
        didSet {
            if allFootsteps.isEmpty { return }
            else {
                DrawOnMap.polylineFromFootsteps(allFootsteps, on: mapView)
            }
        }
    }
    var authStatus: CLAuthorizationStatus { locationManager.authorizationStatus }
    
    override func viewDidLoad() {
        M.mapVC = self
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.tintColor = .clear
        getCurrentLocation()
        initializeMapView()
        M.tableVC.reloadWithNewLocation(coordinate: currentLocation, selected: nil)
        addChild(M.bottomVC)
        view.addSubview(M.bottomVC.view)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            let realm = try! Realm()
            footstepsWithAssets = Array(realm.objects(Footstep.self)).filter({(footstep) -> Bool in !footstep.notes.isEmpty })
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            if overlayOn {
                allFootsteps = Array(realm.objects(Footstep.self)) // automatic overlay
                let annotations = footstepsWithAssets.map { (footstep) -> NearbyAnnotation in
                    return NearbyAnnotation(footstep: footstep, distance: 0)
                }
                mapView.addAnnotations(annotations)
            }
            M.tableVC.allFootsteps = footstepsWithAssets
            M.tableVC.reloadWithNewLocation(coordinate: currentLocation, selected: nil)
        } else { alertForAuthorization() }
    }
    
    @objc func getCurrentLocation() {
        if authStatus == .authorizedAlways || authStatus == .authorizedWhenInUse {
            while locationManager.location == nil {
                locationManager.requestLocation()
            }
            currentLocation = locationManager.location!.coordinate
            mapView.setCenter(currentLocation, animated: false)
        }
    }
    
    func initializeMapView() { // mapView configuration and add all annotations
        mapView.showsUserLocation = true
        mapView.delegate = self
        K.contentHeight = K.screenHeight - (tabBarController?.tabBar.bounds.height)!
        mapView.frame = CGRect(x: 0, y: K.contentHeight / -2, width: K.screenWidth, height: K.contentHeight * 2)
        let camera = MKMapCamera(lookingAtCenter: currentLocation, fromDistance: CLLocationDistance(exactly: 500000)!, pitch: 0, heading: CLLocationDirection(exactly: 0)!)
        mapView.setCamera(camera, animated: false)
        
        let realm = try! Realm()
        footstepsWithAssets = Array(realm.objects(Footstep.self)).filter({(footstep) -> Bool in !footstep.notes.isEmpty })
        M.tableVC.allFootsteps = footstepsWithAssets
        mapView.register(NearbyAnnotationView.self, forAnnotationViewWithReuseIdentifier: NearbyAnnotationView.reuseIdentifier)
        mapView.register(AppleClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        let annotations = footstepsWithAssets.map { (footstep) -> NearbyAnnotation in
            return NearbyAnnotation(footstep: footstep, distance: 0)
        }
        mapView.addAnnotations(annotations)
        view.addSubview(mapView)
        let locationButton = UIButton(frame: CGRect(x: 10, y: 40, width: 45, height: 45))
        locationButton.setImage(#imageLiteral(resourceName: "myLocation"), for: .normal)
        locationButton.addTarget(self, action: #selector(getCurrentLocation), for: .touchUpInside)
        view.addSubview(locationButton)
        
        overlayButton = UIButton(frame: CGRect(x: 14, y: 90, width: 36, height: 36))
        overlayButton.setImage(#imageLiteral(resourceName: "noProfileImage"), for: .normal)
        overlayButton.addTarget(self, action: #selector(toggleOverlay), for: .touchUpInside)
        overlayButton.layer.shadowOffset = .init(width: 0, height: 2.0)
        overlayButton.layer.shadowOpacity = 0.2
        overlayButton.layer.shadowRadius = 2.0
        overlayButton.layer.shadowColor = UIColor.gray.cgColor
        overlayButton.layer.cornerRadius = 2
        overlayButton.alpha = 1
        view.addSubview(overlayButton)
    }
    
    @objc func toggleOverlay() {
        if overlayOn { // turn off overlay
            overlayOn = false
            overlayButton.alpha = 0.6
            mapView.removeAnnotations(mapView.annotations)
            mapView.showsUserLocation = false
        } else { // turn on overlay
            overlayOn = true
            overlayButton.alpha = 1
            let annotations = footstepsWithAssets.map { (footstep) -> NearbyAnnotation in
                return NearbyAnnotation(footstep: footstep, distance: 0)
            }
            mapView.addAnnotations(annotations)
            mapView.showsUserLocation = true
        }
    }
    
    func alertForAuthorization() { // present an alert indicating location authorization required
        // and offer to take the user to Settings for the app via
        // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
        let alert = UIAlertController(title: "위치를 알 수 없어요", message: "소중한 발자취를 위해 위치서비스를 허용해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
            self.tabBarController?.selectedIndex = 0
            alert.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "설정", style: .default, handler: { (_) in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        return
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cluster = annotation as? MKClusterAnnotation {
            var view = mapView.dequeueReusableAnnotationView(withIdentifier: "cluster") as? AppleClusterAnnotationView
            if view == nil {
                view = AppleClusterAnnotationView(annotation: cluster, reuseIdentifier: "cluster")
            }
            return view
        }
        
        if annotation.isKind(of: NearbyAnnotation.self) {
            guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: NearbyAnnotationView.reuseIdentifier) else { fatalError("Cannot create new annotation") }
            return annotationView
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? NearbyAnnotation else { return }
        guard let footstep = annotation.footstep else { return }
        mapView.setCenter(footstep.coordinate, animated: true)
        M.bottomVC.reloadSelectedView(selected: footstep)
        M.tableVC.reloadWithNewLocation(coordinate: footstep.coordinate, selected: footstep)
        mapView.deselectAnnotation(view.annotation, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayWithColor = overlay as! PolylineWithColor
        let polylineView = MKPolylineRenderer(overlay: overlay)
        polylineView.strokeColor = overlayWithColor.color
        polylineView.lineWidth = 7
        return polylineView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !animated && !preventTableUpdate {
            M.bottomVC.reloadSelectedView(selected: nil)
            M.tableVC.reloadWithNewLocation(coordinate: mapView.centerCoordinate, selected: nil)
        }
    }
}

class NearbyAnnotation: MKPointAnnotation {
    
    var footstep: Footstep! = nil
    var distance = 0.0
    
    init(footstep: Footstep, distance: Double) {
        super.init()
        self.coordinate = footstep.coordinate
        self.footstep = footstep
        self.distance = distance
    }
}

class NearbyAnnotationView: MKAnnotationView {
    
    static let reuseIdentifier = "nearby-reuse"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.canShowCallout = true
        self.isEnabled = true
        self.image = #imageLiteral(resourceName: "pin")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            clusteringIdentifier = "ClusteredAnnotation"
        }
    }
}

class AppleClusterAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        displayPriority = .defaultLow
        //collisionMode = .circle
        centerOffset = CGPoint(x: 0, y: -10) // Offset center point to animate better with marker annotations
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var annotation: MKAnnotation? {
        willSet {
            if let cluster = newValue as? MKClusterAnnotation {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
                let count = cluster.memberAnnotations.count
                image = renderer.image { _ in
                    // Fill inner circle with white color
                    UIColor.white.setFill()
                    UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 50, height: 50)).fill()

                    // Finally draw count text vertically and horizontally centered
                    let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                                       NSAttributedString.Key.font: UIFont(name: "NanumBarunPen-Bold", size: 20)]
                    let text = "\(count)"
                    let size = text.size(withAttributes: attributes as [NSAttributedString.Key : Any])
                    let rect = CGRect(x: 33 - size.width / 2, y: 33 - size.height / 2, width: size.width, height: size.height)
                    text.draw(in: rect, withAttributes: attributes as [NSAttributedString.Key : Any])
                }
            }
        }
    }



}
