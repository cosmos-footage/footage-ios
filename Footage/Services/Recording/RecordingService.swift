//
//  RecordingService.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import CoreLocation
import Foundation

protocol RecordingServiceDelegate: AnyObject {
    func recordingService(_ service: RecordingService, didAccept location: CLLocation, distanceMeters: CLLocationDistance, setAsStart: Bool)
    func recordingService(_ service: RecordingService, didReject location: CLLocation, reason: LocationFilter.RejectionReason)
    func recordingService(_ service: RecordingService, didChangeTracking isTracking: Bool)
}

final class RecordingService: NSObject {
    private let locationManager: CLLocationManager
    private let locationFilter: LocationFilter
    private let distanceCalculator: DistanceCalculator
    private let routeRepository: RouteRepository
    private let colorRepository: ColorRepository
    private let placeRepository: PlaceRepository
    private let stateStore: RecordingStateStore
    private let selectedColorProvider: () -> String
    private let isAlwaysOnProvider: () -> Bool
    private let alwaysOnCountProvider: () -> Int
    private let alwaysOnCountSetter: (Int) -> Void

    private var previousLocation: CLLocation?
    private var pendingStartLocation: CLLocation?
    private var setAsStart = true
    private var noSpeedCounter = 0

    weak var delegate: RecordingServiceDelegate?

    init(
        locationManager: CLLocationManager = CLLocationManager(),
        locationFilter: LocationFilter = LocationFilter(),
        distanceCalculator: DistanceCalculator = DistanceCalculator(),
        routeRepository: RouteRepository = RealmRouteRepository(),
        colorRepository: ColorRepository = RealmColorRepository(),
        placeRepository: PlaceRepository = RealmPlaceRepository(),
        stateStore: RecordingStateStore = RecordingStateStore(),
        selectedColorProvider: @escaping () -> String,
        isAlwaysOnProvider: @escaping () -> Bool,
        alwaysOnCountProvider: @escaping () -> Int,
        alwaysOnCountSetter: @escaping (Int) -> Void
    ) {
        self.locationManager = locationManager
        self.locationFilter = locationFilter
        self.distanceCalculator = distanceCalculator
        self.routeRepository = routeRepository
        self.colorRepository = colorRepository
        self.placeRepository = placeRepository
        self.stateStore = stateStore
        self.selectedColorProvider = selectedColorProvider
        self.isAlwaysOnProvider = isAlwaysOnProvider
        self.alwaysOnCountProvider = alwaysOnCountProvider
        self.alwaysOnCountSetter = alwaysOnCountSetter
        super.init()
        self.locationManager.delegate = self
    }

    func startRecording() {
        stateStore.isTracking = true
        configureLocationManager()
        locationManager.startUpdatingLocation()
        delegate?.recordingService(self, didChangeTracking: true)
    }

    func stopRecording() {
        stateStore.isTracking = false
        locationManager.stopUpdatingLocation()
        setAsStart = true
        pendingStartLocation = nil
        delegate?.recordingService(self, didChangeTracking: false)
    }

    func process(location: CLLocation) {
        updateMovementCounters(for: location)

        let alwaysOnCount = alwaysOnCountProvider()
        let decision = locationFilter.decision(
            for: location,
            previous: previousLocation,
            noSpeedCounter: noSpeedCounter,
            alwaysOnCount: alwaysOnCount,
            isAlwaysOn: isAlwaysOnProvider()
        )

        switch decision {
        case .accepted:
            accept(location: location, alwaysOnCount: alwaysOnCount)
        case .rejected(let reason):
            if reason == .alwaysOnWarmup {
                alwaysOnCountSetter(alwaysOnCount + 1)
            } else {
                alwaysOnCountSetter(0)
            }
            setAsStart = true
            delegate?.recordingService(self, didReject: location, reason: reason)
        }

        previousLocation = location
    }

    private func configureLocationManager() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness
    }

    private func updateMovementCounters(for location: CLLocation) {
        if location.speed <= 0.1 {
            noSpeedCounter += 1
        } else {
            noSpeedCounter = 0
        }
    }

    private func accept(location: CLLocation, alwaysOnCount: Int) {
        if setAsStart {
            pendingStartLocation = location
            setAsStart = false
            delegate?.recordingService(self, didAccept: location, distanceMeters: 0, setAsStart: true)
            return
        }

        if let pendingStartLocation = pendingStartLocation {
            persist(location: pendingStartLocation, distance: 0, setAsStart: true)
            self.pendingStartLocation = nil
        }

        let distance = distanceCalculator.distanceMeters(from: previousLocation, to: location)
        persist(location: location, distance: distance, setAsStart: false)
        stateStore.distanceToday += distance
        stateStore.distanceTotal += distance
        delegate?.recordingService(self, didAccept: location, distanceMeters: distance, setAsStart: false)
    }

    private func persist(location: CLLocation, distance: CLLocationDistance, setAsStart: Bool) {
        let color = selectedColorProvider()
        let footstep = Footstep(
            location.timestamp,
            location.coordinate.latitude,
            location.coordinate.longitude,
            color,
            setAsStart
        )

        do {
            try routeRepository.update(footstep: footstep, distance: distance)
            if !setAsStart {
                try colorRepository.update(hex: color, distance: distance)
                placeRepository.update(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    distance: distance
                )
            }
        } catch {
            assertionFailure("Recording persistence failed: \(error)")
        }
    }
}

extension RecordingService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        process(location: location)
    }
}
