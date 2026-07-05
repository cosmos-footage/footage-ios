

import UIKit
import EFCountingLabel

class StatsViewController: UIViewController {
    
    var firstPlace: String = "세종특별자치시"
    var firstColor: String = ""
    var colorRank: Array<(key: String, value: Double)> = []
    var placeRank: Array<(key: String, value: Double)> = []
    var daySummaryRepository: DaySummaryRepository = RealmDaySummaryRepository()
    var colorRepository: ColorRepository = RealmColorRepository()
    var placeRepository: PlaceRepository = RealmPlaceRepository()
    
    @IBOutlet weak var currentBadge: UIImageView!
    @IBOutlet weak var formLastView: UIView!
    @IBOutlet weak var lastButton: UIButton!
    @IBOutlet weak var formStackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var firstBlockFirstLine: UILabel!
    @IBOutlet weak var firstBlockSecondLineFirst: UILabel!
    @IBOutlet weak var firstBlockUnit: UILabel!
    @IBOutlet weak var firstBlockSecondLineSecond: UILabel!
    @IBOutlet weak var firstBlockThirdLine: UILabel!
    @IBOutlet weak var secondBlockFirstLine: UILabel!
    @IBOutlet weak var secondBlockSecondLine: UILabel!
    @IBOutlet weak var secondBlockThirdLine: UILabel!
    @IBOutlet weak var secondBlockFourthLine: UILabel!
    @IBOutlet weak var thirdBlockfirstLineFirst: UILabel!
    @IBOutlet weak var thirdBlockfirstLineSecond: UILabel!
    @IBOutlet weak var thirdBlockSecondLine: UILabel!
    
    @IBOutlet weak var totalDistance: EFCountingLabel!
    @IBOutlet weak var colorImage: UIImageView!
    // add color text label
    @IBOutlet weak var cityImage: UIImageView!
    @IBOutlet weak var cityNickName: UILabel!
    @IBOutlet weak var firstDot: UILabel!
    @IBOutlet weak var secondDot: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        let monthlyDistance = daySummaryRepository.loadMonthlyDistance()
        self.totalDistance.setUpdateBlock { (value, label) in
            label.text = String(format: "%.f", value)
        }
        self.totalDistance.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 7)
        let distance = DistanceTextPresentation(meters: monthlyDistance, style: .integer)
        self.totalDistance.countFrom(0, to: CGFloat(distance.kilometers), withDuration: 5)
        let days = DateConverter.lastMondayToday()
        colorRank = colorRepository.rankingDistance(startDate: days.0, endDate: days.1)
        placeRank = placeRepository.rankingDistance(startDate: days.0, endDate: days.1)
        if !colorRank.isEmpty {
            firstDot.isHidden = false
            secondDot.isHidden = false
            firstColor = colorRank[0].key
            colorImage.image = UIImage(named: firstColor + "Big")
        }
        if !placeRank.isEmpty {
            firstPlace = placeRank[0].key.components(separatedBy: " ").first ?? ""
            setCityImage()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentBadge.image = UIImage(named: UserDefaults.standard.string(forKey: "todayBadge") ?? "")
        colorImage.image = UIImage(named: "noDataImage")
        firstDot.isHidden = true
        secondDot.isHidden = true
        cityImage.image = UIImage(named: "noDataImage")
        cityNickName.text = " - "
        setFontSize()
        setScrollView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "goToLevel":
            let levelVC = segue.destination as! LevelVC
            levelVC.statsVC = self
        case "goToColor":
            let colorVC = segue.destination as! ColorVC
            colorVC.ranking = colorRank
        case "goToPlace":
            let placeVC = segue.destination as! PlaceVC
            placeVC.ranking = placeRank
        default: break
        }
    }
    
    func setCityImage() {
        let city = CityPresentation(sourceName: firstPlace, fallback: .sejong)
        cityImage.image = UIImage(named: city.imageName)
        cityNickName.text = city.nicknameText
    }
    
    func setFontSize() {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        firstBlockFirstLine.font = firstBlockFirstLine.font.withSize(0.0283 * screenHeight)
        firstBlockSecondLineFirst.font = firstBlockSecondLineFirst.font.withSize(0.0283 * screenHeight)
        firstBlockUnit.font = firstBlockUnit.font.withSize(0.0369 * screenHeight)
        firstBlockSecondLineSecond.font = firstBlockSecondLineSecond.font.withSize(0.0283 * screenHeight)
        firstBlockThirdLine.font = firstBlockThirdLine.font.withSize(0.0283 * screenHeight)
        secondBlockFirstLine.font = secondBlockFirstLine.font.withSize(0.0283 * screenHeight)
        secondBlockSecondLine.font = secondBlockSecondLine.font.withSize(0.0283 * screenHeight)
        secondBlockThirdLine.font = secondBlockThirdLine.font.withSize(0.0283 * screenHeight)
        secondBlockFourthLine.font = secondBlockFourthLine.font.withSize(0.0283 * screenHeight)
        thirdBlockfirstLineFirst.font = thirdBlockfirstLineFirst.font.withSize(0.0283 * screenHeight)
        thirdBlockfirstLineSecond.font = thirdBlockfirstLineSecond.font.withSize(0.0283 * screenHeight)
        thirdBlockSecondLine.font = thirdBlockSecondLine.font.withSize(0.0283 * screenHeight)
    }
    
    func setScrollView() {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.delaysContentTouches = true
        formLastView.isExclusiveTouch = true
        scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight)
    }
}
