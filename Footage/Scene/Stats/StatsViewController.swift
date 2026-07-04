

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
        self.totalDistance.countFrom(0, to: CGFloat(monthlyDistance / 1000), withDuration: 5)
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
        switch firstPlace {
        case "서울특별시", "Seoul":
            cityImage.image = UIImage(named: "Seoul")
            cityNickName.text = "\"서울특별시\""
        case "세종특별자치시", "Sejong City":
            cityImage.image = UIImage(named: "Sejong City")
            cityNickName.text = "\"세종특별자치시\""
        case "제주도", "Jeju":
            cityImage.image = UIImage(named: "Jeju")
            cityNickName.text = "\"제주도\""
        case "경기도", "Gyeonggi-do":
            cityImage.image = UIImage(named: "Gyeonggi-do")
            cityNickName.text = "\"경기도\""
        case "대전광역시", "Daejeon":
            cityImage.image = UIImage(named: "Daejeon")
            cityNickName.text = "\"대전광역시\""
        case "울산광역시", "Ulsan":
            cityImage.image = UIImage(named: "Ulsan")
            cityNickName.text = "\"울산광역시\""
        case "광주광역시", "Gwangju":
            cityImage.image = UIImage(named: "Gwangju")
            cityNickName.text = "\"광주광역시\""
        case "부산광역시", "Busan":
            cityImage.image = UIImage(named: "Busan")
            cityNickName.text = "\"부산광역시\""
        case "대구광역시", "Daegu":
            cityImage.image = UIImage(named: "Daegu")
            cityNickName.text = "\"대구광역시\""
        case "강원도", "Gangwon":
            cityImage.image = UIImage(named: "Gangwon")
            cityNickName.text = "\"강원도\""
        case "인천광역시", "Incheon":
            cityImage.image = UIImage(named: "Incheon")
            cityNickName.text = "\"인천광역시\""
        case "충청북도", "North Chungcheong":
            cityImage.image = UIImage(named: "North Chungcheong")
            cityNickName.text = "\"충청북도\""
        case "경상북도", "North Gyeongsang":
            cityImage.image = UIImage(named: "North Gyeongsang")
            cityNickName.text = "\"경상북도\""
        case "전라북도", "North Jeolla":
            cityImage.image = UIImage(named: "North Jeolla")
            cityNickName.text = "\"전라북도\""
        case "충청남도", "South Chungcheong":
            cityImage.image = UIImage(named: "South Chungcheong")
            cityNickName.text = "\"충청남도\""
        case "경상남도", "South Gyeongsang":
            cityImage.image = UIImage(named: "South Gyeongsang")
            cityNickName.text = "\"경상남도\""
        case "전라남도", "South Jeolla":
            cityImage.image = UIImage(named: "South Jeolla")
            cityNickName.text = "\"전라남도\""
        default:
            cityImage.image = UIImage(named: "Sejong City")
            cityNickName.text = "\"세종특별자치시\""
        }
        
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
