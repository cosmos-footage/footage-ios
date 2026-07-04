//
//  ViewController.swift
//  footage
//
//  Created by 녘 on 2020/06/09.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import MapKit
import StoreKit
import UserNotifications
import EFCountingLabel

class HomeViewController: UIViewController {
    
    /// 1. For Home Animation
    static var currentStartButtonImage: UIImage?
    var exampleImageView = UIImageView()
    @IBOutlet weak var mainMap: MKMapView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var StringStackView: UIStackView!
    @IBOutlet weak var youString: UILabel!
    @IBOutlet weak var todayString: UILabel!
    @IBOutlet weak var footString: UILabel!
    @IBOutlet weak var startAboutStackView: UIStackView!
    @IBOutlet weak var distance: EFCountingLabel!
    @IBOutlet weak var distanceView: UIView!
    @IBOutlet weak var unitLabel: UILabel!
    @IBOutlet weak var selectedButtonLabel: UILabel!
    @IBOutlet weak var currentColorIndicator: UIImageView!
    @IBOutlet weak var selectedButtonStackView: UIStackView!
    @IBOutlet weak var MainButton: UIButton!
    @IBOutlet weak var alertDot: UIImageView!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    @IBOutlet weak var fourthButton: UIButton!
    @IBOutlet weak var fifthButton: UIButton!
    @IBOutlet weak var alwaysOnSwitch: UISwitch!
    @IBOutlet weak var extendedStartButtonView: UIView!
    @IBOutlet weak var extendedStartButtonImageView: UIImageView!
    
    @IBAction func questionCircle(_ sender: UIButton) {
        exampleImageView.isHidden = true
    }
    @IBAction func questionCirclePressed(_ sender: UIButton) {
        exampleImageView.isHidden = false
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        keyWindow?.addSubview(exampleImageView)
        keyWindow?.bringSubviewToFront(exampleImageView)
    }
    @IBAction func extendClosePressed(_ sender: Any) {
        extendedStartButtonView.isHidden = true
        view.sendSubviewToBack(extendedStartButtonView)
    }
    
    @IBAction func categoryPressed(_ sender: UIButton) {
        HomeAnimation.buttonChanger(homeVC: self, pressedbutton: sender)
        HomeAnimation.colorSelected(homeVC: self, pressedbutton: sender)
    }
    
    /// 2. For MapKit
    private static let recordingStateStore = RecordingStateStore()
    static var distanceToday: Double = 0 {
        didSet {
            recordingStateStore.distanceToday = distanceToday
        }
    }
    static var distanceTotal: Double = 0 {
        didSet {
            recordingStateStore.distanceTotal = distanceTotal
        }
    }
    static let locationManager = CLLocationManager()
    var dateFormatter =  DateFormatter()
    var nextLocation: CLLocation?
    var saveStart: CLLocation?
    var lastLocation: CLLocation?
    var locationTimer: Timer?
    var setAsStart: Bool = true
    var speedLimit: Double = 8
    var refreshRate: Double = 2.5
    var distanceLimit: Double { speedLimit * refreshRate }
    lazy var startedBefore = UserDefaults.standard.bool(forKey: "startedBefore")
    static var selectedColor: String = "#EADE4Cff"
    var speedCounter: Int = 0
    var noSpeedCounter: Int = 0
    var isWalking: Int = 0
    var timer = Timer()
    var lauchingCount: Int?
    var latestVersion: Int = 123
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkUpdate() //set UserDafaults which doesn't related to StartButton when App is updated and need to set new UD
        setDelegates()
        prepareForAnimation()
        HomeAnimation.homeStopAnimation(self)
        configureInitialMapView()
        setExampleImageView()
        alwaysOnSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        if UIApplication.shared.applicationIconBadgeNumber == 0 {
            alertDot.isHidden = true
        } else {
            alertDot.isHidden = false
            view.bringSubviewToFront(alertDot)
        }
        if HomeViewController.recordingStateStore.isTracking {
            startTracking()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkUpdateInVDA()
        if !startedBefore {
            Settings_GeneralVC.registerNoti()
            HomeViewController.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    @IBAction func startButtonLongPressed(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.extendedStartButtonView.isHidden = false
            self.view.bringSubviewToFront(self.extendedStartButtonView)
            UIView.transition(with: self.extendedStartButtonImageView, duration: 1, options: .curveEaseIn) {
                self.extendedStartButtonImageView.image = #imageLiteral(resourceName: "extendedStartButton")
            }
        }
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        if startButton.currentImage == #imageLiteral(resourceName: "startButton") { // FROM START TO STOP
            startTracking()
        } else { // FROM STOP TO START
            stopTracking()
        }
    }
    
    func startTracking() {
        HomeViewController.recordingStateStore.isTracking = true
        HomeViewController.distanceToday = DateManager.loadDistance(total: false)
        HomeViewController.currentStartButtonImage = #imageLiteral(resourceName: "stopButton")
        UIApplication.shared.applicationIconBadgeNumber = 0
        alertDot.isHidden = true
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied {
            alertForAuthorization()
        } else {
            if UserDefaults.standard.bool(forKey: "startedBefore") == false {
                setUserDefaults()
                LevelManager.firstLaunch()
                BadgeGiver.gotBadge(view: view, badge: Badge(type: "place", imageName: "starter_level", detail: "이 지역에 이제 막 발자취를 남기기 시작했습니다."))
                Settings_GeneralVC.noti_everyMonthAlert()
                Settings_GeneralVC.noti_everydayAlert()
            }
            checkUpdateInHB() //set UserDafaults which related to HomeButton when App is updated and need to set new UD
            HomeAnimation.homeStartAnimation(self)
            HomeViewController.selectedColor = Buttons(className: MainButton.restorationIdentifier!).color
            trackMapView()
            
            let center = UNUserNotificationCenter.current()
            center.getPendingNotificationRequests(completionHandler: { requests in
                for request in requests {
                    print(request)
                }
            })
        }
    }
    
    func stopTracking() {
        HomeViewController.recordingStateStore.isTracking = false
        locationTimer?.invalidate() // stop location request
        HomeViewController.locationManager.stopUpdatingLocation()
        HomeViewController.currentStartButtonImage = #imageLiteral(resourceName: "startButton")
        setAsStart = true // next coordinate must be set as new start point
        HomeAnimation.homeStopAnimation(self)
        configureInitialMapView()
    }
}

// MARK: - Map Kit View

extension HomeViewController: CLLocationManagerDelegate, MKMapViewDelegate  {
    
    func configureInitialMapView() {
        var coordinate: CLLocationCoordinate2D? = nil
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            while HomeViewController.locationManager.location == nil {
                HomeViewController.locationManager.requestLocation()
            }
            coordinate = HomeViewController.locationManager.location!.coordinate
        } else { // default location for when location data is not authorized
            coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(exactly: 36.5151)!, CLLocationDegrees(exactly: 127.2385)!)
        }
        let spanValue = MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
        let locationRegion = MKCoordinateRegion(center: coordinate!, span: spanValue)
        mainMap.mapType = MKMapType.standard
        mainMap.setRegion(locationRegion, animated: true)
        mainMap.showsUserLocation = true
        // draw all routes
        //        for journey in DateManager.loadFromRealm(rangeOf: "year") {
        //            DrawOnMap.polylineFromFootsteps(Array(journey.footsteps), on: mainMap)
        //        }
        UIView.animate(withDuration: 1) {
            self.mainMap.alpha = 1
        }
    }
    
    func trackMapView() {
        dateFormatter.dateFormat = "yyyyMMdd"
        let today = dateFormatter.string(from: Date())
        HomeViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        HomeViewController.locationManager.distanceFilter = 5 // meters
        HomeViewController.locationManager.pausesLocationUpdatesAutomatically = true
        HomeViewController.locationManager.allowsBackgroundLocationUpdates = true
        HomeViewController.locationManager.activityType = .fitness
        
        for journey in DateManager.loadFromRealm(rangeOf: today) { // draw previous routes from today
            DrawOnMap.polylineFromFootsteps(Array(journey.footsteps), on: mainMap)
        }
        
        UIView.animate(withDuration: 1) {
            self.mainMap.alpha = 1
            self.mainMap.setCamera(.init(lookingAtCenter: self.mainMap.centerCoordinate, fromDistance: 500, pitch: 0, heading: 0), animated: false)
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            while HomeViewController.locationManager.location == nil {
                HomeViewController.locationManager.requestLocation()
            }
            HomeViewController.locationManager.startUpdatingLocation()
            self.lastLocation = HomeViewController.locationManager.location
        }
    }
    
    // DID UPDATE
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        nextLocation = locations[0]
        checkForMovement(location: nextLocation)
        guard let nextLocation = nextLocation else { return }
        guard let lastLocation = lastLocation else { return }
        if isValid(location: nextLocation) {
            if setAsStart { // now began to walk
                saveStart = nextLocation
                setAsStart = false
            } else { // continue walking
                if let startLocation = saveStart {
                    LocationUpdate.processNewLocation(location: startLocation, distance: 0, setAsStart: true, color: HomeViewController.selectedColor)
                    saveStart = nil
                }
                let newDistance = nextLocation.distance(from: lastLocation)
                LocationUpdate.processNewLocation(location: nextLocation, distance: newDistance, setAsStart: false, color: HomeViewController.selectedColor)
                self.extendPolyline(lastLocation: lastLocation, newLocation: nextLocation)
                HomeViewController.distanceToday += newDistance
                distance.text = String(format: "%.2f", (HomeViewController.distanceToday)/1000)
                HomeViewController.distanceTotal += newDistance
                BadgeGiver.checkDistance(view: view)
                BadgeGiver.cityCheck(view: view)
                DateManager.saveTotalDistance(value: HomeViewController.distanceTotal)
            }
        } else { setAsStart = true } // you are on a bus
        self.lastLocation = nextLocation
        mainMap.setCenter(nextLocation.coordinate, animated: true)
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        HomeViewController.currentStartButtonImage = #imageLiteral(resourceName: "startButton")
        setAsStart = true // next coordinate must be set as new start point
        HomeAnimation.homeStopAnimation(self)
        configureInitialMapView()
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        HomeAnimation.homeStartAnimation(self)
        HomeViewController.selectedColor = Buttons(className: MainButton.restorationIdentifier!).color
        trackMapView()
    }
    
    func isValid(location: CLLocation) -> Bool { // check speed, distance etc with lastLocation
        if checkSpeed(lastLocation: lastLocation ?? location, newLocation: location) > speedLimit || location.distance(from: lastLocation ?? location) > distanceLimit {
            // Valid의 근본적 제한 요소 (제한속도 이상, 두 점이 제한 거리 이상)
            UserDefaults.standard.setValue(0, forKey:"alwaysOnCount")
            return false
        } else if UserDefaults.standard.bool(forKey: "alwaysOn") && noSpeedCounter>4 {
            // Valid의 근본적 제한 요소2 (alwaysOn이 true일때 noSpeedCounter의 횟수가 4회 이상일 경우, 즉 실내로 판단될 경우)
            // speedCounter를 따로 판단하지 않는 이유는 위에서의 speedLimit에서 걸러지기 때문
            UserDefaults.standard.setValue(0, forKey:"alwaysOnCount")
            return false
        } else if let lastLocation = lastLocation { //이전 위치가 있다면,
            //혹은 이전 직전의 위치와 현재의 위치에서의 속도가 모두 0보다 작을 경우 즉, 움직임이 없을 경우
            if location.speed < 0.1 && lastLocation.speed < 0.1 {
                UserDefaults.standard.setValue(0, forKey:"alwaysOnCount")
                return false
            } else {
                if UserDefaults.standard.bool(forKey: "alwaysOn"){
                    let alwaysOnCount = UserDefaults.standard.integer(forKey: "alwaysOnCount") // alwaysOn이 true일때 오차값을 기록하지 않기 위한 장치
                    if alwaysOnCount < 4 { // 일정 횟수를 넘어야 true를 반환할 수 있도록 함.
                        UserDefaults.standard.set(alwaysOnCount + 1, forKey: "alwaysOnCount")
                        return false
                    } else {
                        return true
                    }
                }
                return true
            }
        } else { noSpeedCounter = 0; return true } // 이전 위치가 없다면,
        
    }
    
    func checkForMovement(location: CLLocation?) {
        guard let location = location else { return }
        if location.speed > speedLimit { speedCounter += 1 }
        else { speedCounter = 0 }
        if location.speed <= 0.1 { noSpeedCounter += 1 }
        else { noSpeedCounter = 0 }
        
        if speedCounter == 4 {
            if !UserDefaults.standard.bool(forKey: "alwaysOn") {
                noti_recordStoppedBySpeed()
                locationTimer?.invalidate() // stop location request
                HomeViewController.locationManager.stopUpdatingLocation()
                HomeViewController.currentStartButtonImage = #imageLiteral(resourceName: "startButton")
                setAsStart = true // next coordinate must be set as new start point
                HomeAnimation.homeStopAnimation(self)
                configureInitialMapView()
                speedCounter = 0
                return
            }
            
        } else if noSpeedCounter == 7 {
            if !UserDefaults.standard.bool(forKey: "alwaysOn") {
                noti_recordStoppedByNoSpeed()
                locationTimer?.invalidate() // stop location request
                HomeViewController.locationManager.stopUpdatingLocation()
                HomeViewController.currentStartButtonImage = #imageLiteral(resourceName: "startButton")
                setAsStart = true // next coordinate must be set as new start point
                HomeAnimation.homeStopAnimation(self)
                configureInitialMapView()
                noSpeedCounter = 0
                return
            }
        }
    }
    
    func extendPolyline(lastLocation: CLLocation, newLocation: CLLocation) {
        let newLine = MKPolyline(coordinates: [lastLocation.coordinate, newLocation.coordinate], count: 2)
        self.mainMap.addOverlay(newLine)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlayWithColor = overlay as? PolylineWithColor {
            let polylineView = MKPolylineRenderer(overlay: overlay)
            polylineView.strokeColor = overlayWithColor.color
            polylineView.lineWidth = 7
            return polylineView
        } else {
            let polylineView = MKPolylineRenderer(overlay: overlay)
            polylineView.strokeColor = UIColor(hex: HomeViewController.selectedColor)
            polylineView.lineWidth = 7
            return polylineView
        }
    }
    
    func setMapRegion(latitude: CLLocationDegrees, longitude: CLLocationDegrees, delta: Double){
        let coordinateLocation = CLLocationCoordinate2DMake(latitude, longitude)
        let spanValue = MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        let locationRegion = MKCoordinateRegion(center: coordinateLocation, span: spanValue)
        mainMap.setRegion(locationRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func checkSpeed(lastLocation: CLLocation, newLocation: CLLocation) -> Double {
        let timeInterval = newLocation.timestamp.timeIntervalSince(lastLocation.timestamp)
        let distanceInterval = newLocation.distance(from: lastLocation)
        return distanceInterval / timeInterval
    }
    
    // MARK:- Notification
    
    func noti_recordStoppedBySpeed() {
        if UserDefaults.standard.bool(forKey: "etcPush") {
            let content = UNMutableNotificationContent()
            content.title = "속도 제한 초과"
            content.body = "발자취를 남긴다는 건, 주위를 온전히 담아낼 수 있어야 한다는 것."
            content.badge = 1
            content.sound = UNNotificationSound.default
            alertDot.isHidden = false
            alertDot.alpha = 0
            view.bringSubviewToFront(alertDot)
            UIView.animate(withDuration: 1) {
                self.alertDot.alpha = 1
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let randomIdentifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: randomIdentifier, content: content, trigger: trigger)
            
            // 3
            UNUserNotificationCenter.current().add(request) { error in
                if error != nil {
                    print("something went wrong")
                }
            }
            
            let youSureAlert = UIAlertController.init(title: "속도 제한 초과", message: "발자취를 남긴다는 건, 주위를 온전히 담아낼 수 있어야 한다는 것.", preferredStyle:  .alert)
            self.present(youSureAlert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                youSureAlert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func noti_recordStoppedByNoSpeed() {
        if UserDefaults.standard.bool(forKey: "etcPush") {
            let content = UNMutableNotificationContent()
            content.title = "기록 중지"
            content.body = "어딘가에 머물러 짙은 발자취를 남기시나보군요. 잠시 기록을 중단하겠습니다."
            content.badge = 1
            content.sound = UNNotificationSound.default
            alertDot.isHidden = false
            alertDot.alpha = 0
            view.bringSubviewToFront(alertDot)
            UIView.animate(withDuration: 1) {
                self.alertDot.alpha = 1
            }
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let randomIdentifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: randomIdentifier, content: content, trigger: trigger)
            
            // 3
            UNUserNotificationCenter.current().add(request) { error in
                if error != nil {
                    print("something went wrong")
                }
            }
            
            let youSureAlert = UIAlertController.init(title: "기록 중지", message: "어딘가에 머물러 짙은 발자취를 남기시나보군요. 잠시 기록을 중단하겠습니다.", preferredStyle:  .alert)
            self.present(youSureAlert, animated: true, completion: nil)
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                youSureAlert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setToLastCategory(selectedColor: String?){
        guard let selectedColor = selectedColor else { return }
        switch selectedColor {
        case "#EADE4Cff": // default
            break
        case "#F5A997ff":
            HomeAnimation.buttonChanger(homeVC: self, pressedbutton: secondButton)
            HomeAnimation.colorSelected(homeVC: self, pressedbutton: secondButton)
        case "#F0E7CFff":
            HomeAnimation.buttonChanger(homeVC: self, pressedbutton: thirdButton)
            HomeAnimation.colorSelected(homeVC: self, pressedbutton: thirdButton)
        case "#FF6B39ff":
            HomeAnimation.buttonChanger(homeVC: self, pressedbutton: fourthButton)
            HomeAnimation.colorSelected(homeVC: self, pressedbutton: fourthButton)
        case "#206491ff":
            HomeAnimation.buttonChanger(homeVC: self, pressedbutton: fifthButton)
            HomeAnimation.colorSelected(homeVC: self, pressedbutton: fifthButton)
        default:
            break
        }
    }
}

// MARK: -Others
extension HomeViewController {
    
    func prepareForAnimation() {
        extendedStartButtonView.isHidden = true
        exampleImageView.isHidden = true
        startButton.setImage(#imageLiteral(resourceName: "startButton"), for: .normal)
        HomeViewController.currentStartButtonImage = startButton.currentImage
        selectedButtonLabel.text = UserDefaults(suiteName: "group.footage")?.string(forKey: "#EADE4Cff")
        mainMap.tintColor = UIColor(hex: "#EADE4Cff")
        startButton.alpha = 0
        distanceView.alpha = 0
        unitLabel.alpha = 0
        unitLabel.font = unitLabel.font.withSize(0.061 * HomeAnimation.screenHeight)
        distance.font = distance.font.withSize(0.08 * HomeAnimation.screenHeight)
        self.view.bringSubviewToFront(StringStackView)
        self.view.bringSubviewToFront(startAboutStackView)
        if UserDefaults.standard.bool(forKey: "alwaysOn") {
            alwaysOnSwitch.setOn(true, animated: true)
        } else {
            alwaysOnSwitch.setOn(false, animated: true)
        }
    }
    
    func setDelegates() {
        mainMap.delegate = self
        HomeViewController.locationManager.delegate = self
        //        self.requestNotificationAuthorization()
    }
    
    func alertForAuthorization() { // present an alert indicating location authorization required
        // and offer to take the user to Settings for the app via
        // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
        let alert = UIAlertController(title: "위치를 알 수 없어요", message: "소중한 발자취를 위해 위치서비스를 허용해주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (_) in
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
    
    func setExampleImageView() {
        exampleImageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: -10), size: CGSize(width: K.screenWidth, height: K.screenHeight*1.1)))
        exampleImageView.image = #imageLiteral(resourceName: "HomeExampleImage")
        view.addSubview(exampleImageView)
        view.bringSubviewToFront(exampleImageView)
        exampleImageView.isHidden = true
    }
    
    func checkUpdate() { // 어플 실행시 확인하는 것
        if UserDefaults.standard.object(forKey: "version") == nil {
            UserDefaults.standard.set(latestVersion, forKey: "version")
            UserDefaults.standard.set(false, forKey: "isUpdated")
        } else {
            UserDefaults.standard.setValue(latestVersion, forKey: "version")
            UserDefaults.standard.setValue(false, forKey: "isUpdated")
            // 앞으로 업데이트 시 여기에 integer값으로 버전 입력하고 업데이트 사항 반영
        }
        
        if UserDefaults.standard.integer(forKey: "version") == latestVersion {
            if !UserDefaults.standard.bool(forKey: "isUpdated") {
                UserDefaults.standard.set(true, forKey: "isUpdated")
            }
        } else if UserDefaults.standard.integer(forKey: "version") == 120 {
            if !UserDefaults.standard.bool(forKey: "isUpdated") {
                UserDefaults.standard.set(false, forKey: "alwaysOn")
                //alwaysOn이 켜져있을 때 연속해서 유효한 위치값이 연속으로 나타나야 isValid를 true로 반환할 수 있도록 하는 userdefaults
                UserDefaults.standard.set(0, forKey: "alwaysOnCount")
                UserDefaults.standard.set(0, forKey: "launchingCount")
                UserDefaults.standard.set(0, forKey: "minimumTotalRecord")
                guard let widgetUD = UserDefaults(suiteName: "group.footage") else { return }
                widgetUD.set("#EADE4Cff", forKey: "selectedColor")
                
                let hexValues = ["#EADE4Cff", "#F5A997ff", "#F0E7CFff", "#FF6B39ff", "#206491ff"]
                for hex in hexValues {
                    guard let categoryName = UserDefaults.standard.string(forKey: hex) else { continue }
                    widgetUD.set(categoryName, forKey: hex)
                }
                UserDefaults(suiteName: "group.footage")!.set("#EADE4Cff", forKey: "selectedColor")
                
            }
        }
        
        
    }
    
    func checkUpdateInHB() { // 홈버튼 누를때 확인하는 것
        lauchingCount = UserDefaults.standard.integer(forKey: "launchingCount")
        if lauchingCount ?? 0 >= 5 {
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set(0, forKey: "launchingCount")
        } else {
            UserDefaults.standard.set((lauchingCount ?? 0) + 1, forKey: "launchingCount")
        }
    }
    
    func checkUpdateInVDA(){
        if !UserDefaults.standard.bool(forKey: "isUpdated") {
            if UserDefaults.standard.integer(forKey: "version") == 120 {
                let updatingAlert = UIAlertController.init(title: "업데이트 중", message: "장소별 배지를 조금 손보았어요.", preferredStyle:  .alert)
                self.present(updatingAlert, animated: true, completion: nil)
                Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                    updatingAlert.dismiss(animated: true, completion: nil)
                }
                DispatchQueue.global().sync {
                    LevelManager.deleteTypeBadge(badgeType: "place")
                    BadgeGiver.restorePlaceBadge()
                }
                UserDefaults.standard.set(true, forKey: "isUpdated")
            } else if UserDefaults.standard.integer(forKey: "version") == latestVersion {
                UserDefaults.standard.set(true, forKey: "isUpdated")
            }
        }
    }
    
    func setUserDefaults() {
        UserDefaults.standard.setValue(true, forKey: "startedBefore")
        UserDefaults.standard.setValue(false, forKey: "alwaysOn")
        UserDefaults.standard.setValue(0, forKey: "alwaysOnCount")
        UserDefaults.standard.setValue(0, forKey: "launchingCount")
        UserDefaults.standard.setValue(true, forKey: "everydayPush")
        UserDefaults.standard.setValue(true, forKey: "etcPush")
        UserDefaults.standard.setValue(10, forKey: "everydayPushHour")
        UserDefaults.standard.setValue(30, forKey: "everydayPushMinute")
        UserDefaults(suiteName: "group.footage")!.setValue("#EADE4Cff", forKey: "selectedColor")
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender == alwaysOnSwitch {
            if sender.isOn {
                let status = CLLocationManager.authorizationStatus()
                if status != .authorizedAlways {
                    HomeViewController.locationManager.requestAlwaysAuthorization()
                    self.alwaysOnSwitch.setOn(false, animated: true)
                } else {
                    UserDefaults.standard.set(true, forKey: "alwaysOn")
                }
            } else {
                UserDefaults.standard.set(false, forKey: "alwaysOn")
            }
        }
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
