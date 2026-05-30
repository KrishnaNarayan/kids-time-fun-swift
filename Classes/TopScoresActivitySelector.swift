import UIKit

class TopScoresActivitySelector: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activity: Int32 = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kStrTopScores
        let btn = UIBarButtonItem(image: UIImage(named: "Top Scores"), style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = btn
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(kNumberOfActivities)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "Activity"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ??
            UITableViewCell(style: .default, reuseIdentifier: id)

        cell.accessoryView = UIImageView(image: UIImage(named: "RightArrowAccessory"))
        cell.textLabel?.textColor = .white

        switch Int32(indexPath.row) {
        case kActTellTime:
            cell.backgroundColor = UIColor(red: 0.956, green: 0.423, blue: 0.109, alpha: 0.50)
            cell.textLabel?.text = kStrTellTime
        case kActSetTime:
            cell.backgroundColor = UIColor(red: 0.408, green: 0.0, blue: 0.972, alpha: 0.50)
            cell.textLabel?.text = kStrSetTime
        case kActTimeAfter:
            cell.backgroundColor = UIColor(red: 0.984, green: 0.0, blue: 0.972, alpha: 0.50)
            cell.textLabel?.text = kStrTimeAfter
        case kActTimeBefore:
            cell.backgroundColor = UIColor(red: 0.043, green: 0.808, blue: 0.11, alpha: 0.50)
            cell.textLabel?.text = kStrTimeBefore
        case kActElapsedTime:
            cell.backgroundColor = UIColor(red: 0.043, green: 0.349, blue: 0.976, alpha: 0.50)
            cell.textLabel?.text = kStrElapsedTime
        case kActMixed:
            cell.backgroundColor = UIColor(patternImage: UIImage(named: "MixedPattern")!)
            cell.textLabel?.text = kStrMixed
        default: break
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        activity = Int32(indexPath.row)
        let nib = UIDevice.current.userInterfaceIdiom == .pad
            ? "TopScoresActivityLevelSelectorView-iPad"
            : "TopScoresActivityLevelSelectorView"
        let vc = TopScoresActivityLevelSelector(nibName: nib, bundle: nil)
        vc.activity = activity
        vc.activityLevel = kActLevelNone
        navigationController?.pushViewController(vc, animated: true)
    }
}
