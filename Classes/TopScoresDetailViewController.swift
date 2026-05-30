import UIKit

class TopScoresDetailViewController: UITabBarController {

    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var showActivityTypeSelection: Bool = false

    convenience init(activity act: Int32, andType type: Int32, andLevel level: Int32,
                     showActivityTypeSelection show: Bool,
                     withNibName nib: String?, andBundle bundle: Bundle?) {
        self.init(nibName: nib, bundle: bundle)
        activity = act; activityType = type; activityLevel = level
        showActivityTypeSelection = show
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let activityName: String
        switch activity {
        case kActTellTime: activityName = kStrTellTime
        case kActElapsedTime: activityName = kStrElapsedTime
        case kActTimeAfter: activityName = kStrTimeAfter
        case kActTimeBefore: activityName = kStrTimeBefore
        case kActSetTime: activityName = kStrSetTime
        case kActMixed: activityName = kStrMixed
        default: activityName = ""
        }

        let levelName: String
        switch activityLevel {
        case kActLevelYellowBelt: levelName = "Yellow Belt"
        case kActLevelGreenBelt:  levelName = "Green Belt"
        case kActLevelRedBelt:    levelName = "Red Belt"
        case kActLevelBlackBelt:  levelName = "Black Belt"
        default: levelName = ""
        }

        title = "\(activityName) - \(levelName)"

        let nibName = UIDevice.current.userInterfaceIdiom == .pad
            ? "TopScoresSingleDetailView-iPad"
            : "TopScoresSingleDetailView"

        let numberedVC = TopScoresSingleDetailViewController(activity: activity, andType: kActTypeNumbered, andLevel: activityLevel, withNibName: nibName, bundle: nil)
        let timedVC = TopScoresSingleDetailViewController(activity: activity, andType: kActTypeTimed, andLevel: activityLevel, withNibName: nibName, bundle: nil)
        numberedVC.title = "Numbered"; timedVC.title = "Timed"

        if showActivityTypeSelection {
            numberedVC.tabBarItem = UITabBarItem(title: "Numbered", image: UIImage(named: "Numbered.png"), tag: Int(kActTypeNumbered))
            timedVC.tabBarItem = UITabBarItem(title: "Timed", image: UIImage(named: "Timed.png"), tag: Int(kActTypeTimed))
        }

        viewControllers = [numberedVC, timedVC]
    }
}
