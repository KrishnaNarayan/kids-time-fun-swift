import UIKit

@objc(TopScoresActivityLevelSelector)
class TopScoresActivityLevelSelector: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activity: Int32 = 0
    var activityLevel: Int32 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
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
        title = "\(kStrTopScores) - \(activityName)"
        let btn = UIBarButtonItem(image: UIImage(named: "Top Scores"), style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = btn
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(kNumberOfActivityLevels)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "Activity"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ??
            UITableViewCell(style: .default, reuseIdentifier: id)

        cell.accessoryView = UIImageView(image: UIImage(named: "RightArrowAccessory"))
        cell.textLabel?.textColor = .white

        let colors: [Int32: UIColor] = [
            kActTellTime:    UIColor(red: 0.956, green: 0.423, blue: 0.109, alpha: 0.50),
            kActSetTime:     UIColor(red: 0.408, green: 0.0,   blue: 0.972, alpha: 0.50),
            kActTimeAfter:   UIColor(red: 0.984, green: 0.0,   blue: 0.972, alpha: 0.50),
            kActTimeBefore:  UIColor(red: 0.043, green: 0.808, blue: 0.11,  alpha: 0.50),
            kActElapsedTime: UIColor(red: 0.043, green: 0.349, blue: 0.976, alpha: 0.50),
            kActMixed:       UIColor(patternImage: UIImage(named: "MixedPattern")!)
        ]
        cell.backgroundColor = colors[activity] ?? .clear

        switch indexPath.row {
        case Int(kActLevelYellowBelt): cell.imageView?.image = UIImage(named: "Yellow Belt"); cell.textLabel?.text = "Yellow Belt"
        case Int(kActLevelGreenBelt):  cell.imageView?.image = UIImage(named: "Green Belt");  cell.textLabel?.text = "Green Belt"
        case Int(kActLevelRedBelt):    cell.imageView?.image = UIImage(named: "Red Belt");    cell.textLabel?.text = "Red Belt"
        case Int(kActLevelBlackBelt):  cell.imageView?.image = UIImage(named: "Black Belt");  cell.textLabel?.text = "Black Belt"
        default: break
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        activityLevel = Int32(indexPath.row)
        let nib = UIDevice.current.userInterfaceIdiom == .pad
            ? "TopScoresDetailView-iPad" : "TopScoresDetailView"
        let vc = TopScoresDetailViewController(activity: activity, andType: KidsTimeFunAppState.sharedState().activityType,
                                               andLevel: activityLevel, showActivityTypeSelection: true,
                                               withNibName: nib, andBundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
}
