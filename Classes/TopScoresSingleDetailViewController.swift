import UIKit

class TopScoresSingleDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var scoresArray: [[String: Any]] = []

    convenience init(activity act: Int32, andType type: Int32, andLevel level: Int32,
                     withNibName nib: String?, bundle: Bundle?) {
        self.init(nibName: nib, bundle: bundle)
        activity = act; activityType = type; activityLevel = level
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadScores()
    }

    func loadScores() {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = String(format: kFileVarScores, activity, activityType, activityLevel)
        let path = docs + "/" + fileName
        scoresArray = (NSArray(contentsOfFile: path) as? [[String: Any]]) ?? []
    }

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(scoresArray.count, 1)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "Activity"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ??
            UITableViewCell(style: .default, reuseIdentifier: id)

        if !scoresArray.isEmpty {
            let score = scoresArray[indexPath.row]
            var text = "\(indexPath.row + 1). "
            text += (score[kPlayerName] as? String) ?? ""
            text += ", "
            if activityType == kActTypeNumbered {
                let pct = (score[kPercentScore] as? NSNumber)?.floatValue ?? 0
                let right = (score[kRightAnswers] as? NSNumber)?.intValue ?? 0
                let wrong = (score[kWrongAnswers] as? NSNumber)?.intValue ?? 0
                text += String(format: "%1.0f%%, %i right, %i wrong, ", pct * 100, right, wrong)
            } else {
                let r = (score[kRightAnswers] as? NSNumber)?.intValue ?? 0
                let w = (score[kWrongAnswers] as? NSNumber)?.intValue ?? 0
                text += "\(r + w) questions, "
            }
            text += "\((score[kSecondsTaken] as? NSNumber)?.intValue ?? 0) sec"
            cell.textLabel?.text = text
        } else {
            cell.textLabel?.text = kStrBlank
        }

        let fontSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 24 : 15
        cell.textLabel?.font = UIFont(name: "Helvetica", size: fontSize)
        cell.textLabel?.textColor = UIColor(red: 0.043, green: 0.376, blue: 0.996, alpha: 1)
        cell.backgroundColor = UIColor(white: 1, alpha: 0.25)
        return cell
    }
}
