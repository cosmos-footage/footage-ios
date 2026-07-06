//
//  RenewedMapViewController.swift
//  footage
//
//  Created by Codex on 2026/07/06.
//

import MapKit
import UIKit

final class RenewedMapViewController: UIViewController {
    let mapView = MKMapView()

    init() {
        super.init(nibName: nil, bundle: nil)
        title = "지도"
        tabBarItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map"), selectedImage: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
    }

    private func configureMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.pointOfInterestFilter = .includingAll
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
