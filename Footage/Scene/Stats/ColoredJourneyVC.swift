//
//  ColoredJourneyVC.swift
//  footage
//
//  Created by Wootae on 7/4/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit

class ColoredJourneyVC: UIViewController, MKMapViewDelegate {
    var color: String = ""
    var colorRepository: ColorRepository = RealmColorRepository()
    @IBOutlet weak var mainMap: MKMapView!
    @IBOutlet weak var colorImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainMap.delegate = self
        configureMap()
        setColorImage(name: color)
    }
    
    func loadJourney() {
        
    }
    
    func configureMap() {
        let days = DateConverter.lastMondayToday()
        let footstepsArray = colorRepository.footsteps(hex: color, from: days.0, to: days.1)
        for footsteps in footstepsArray {
            DrawOnMap.polylineFromFootsteps(Array(footsteps), on: mainMap)
        }
        guard let initial = mainMap.overlays.first?.boundingMapRect else { return }
        let mapRect = mainMap.overlays
            .dropFirst()
            .reduce(initial) { $0.union($1.boundingMapRect) }
        let insets = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        mainMap.setVisibleMapRect(mapRect, edgePadding: insets, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let overlayWithColor = overlay as! PolylineWithColor
        let polylineView = MKPolylineRenderer(overlay: overlay)
        polylineView.strokeColor = overlayWithColor.color
        polylineView.lineWidth = 10
        return polylineView
    }
    
    func setColorImage(name: String) {
        colorImage.image = UIImage(named: name)
    }
}
