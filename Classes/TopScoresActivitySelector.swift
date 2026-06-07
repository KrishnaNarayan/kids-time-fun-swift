// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

/// "Rank Belts" — shows, per activity, the belt the child has earned at the
/// selected grade level (or "No belt yet"). Belts are earned by passing the
/// belt-progression ladder and are tracked separately for each grade.
@objc(TopScoresActivitySelector)
class TopScoresActivitySelector: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var activity: Int32 = 0
    private var displayGrade: Int32 = 0

    // Mostly-opaque row colors so the white text + belt names stay legible over the
    // sky/rainbow background (the old 0.50 alpha let the art bleed through).
    private let activityColors: [Int32: UIColor] = [
        kActTellTime:    UIColor(red: 0.956, green: 0.423, blue: 0.109, alpha: 0.92),
        kActSetTime:     UIColor(red: 0.408, green: 0.0,   blue: 0.972, alpha: 0.92),
        kActTimeAfter:   UIColor(red: 0.984, green: 0.0,   blue: 0.972, alpha: 0.92),
        kActTimeBefore:  UIColor(red: 0.043, green: 0.808, blue: 0.11,  alpha: 0.92),
        kActElapsedTime: UIColor(red: 0.043, green: 0.349, blue: 0.976, alpha: 0.92)
    ]

    private func activityName(_ a: Int32) -> String {
        switch a {
        case kActTellTime:    return kStrTellTime
        case kActTimeBefore:  return kStrTimeBefore
        case kActTimeAfter:   return kStrTimeAfter
        case kActElapsedTime: return kStrElapsedTime
        case kActSetTime:     return kStrSetTime
        case kActMixed:       return kStrMixed
        default:              return ""
        }
    }

    // Short, consistent grade names for the Rank Belts switcher.
    private let gradeTitles = ["1st Grade", "2nd Grade", "3rd Grade"]

    private lazy var gradeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: gradeTitles)
        control.selectedSegmentIndex = Int(displayGrade)
        control.addTarget(self, action: #selector(gradeChanged(_:)), for: .valueChanged)
        return control
    }()

    private weak var beltTable: UITableView?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutLegacyTableAndBackground()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        title = kStrRankBelts
        displayGrade = KidsTimeFunAppState.sharedState().gradeLevel
        gradeControl.selectedSegmentIndex = Int(displayGrade)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: kStrRankBelts, style: .plain, target: nil, action: nil)
        let infoBtn = UIBarButtonItem(image: UIImage(systemName: "info.circle"),
                                      style: .plain, target: self, action: #selector(showBeltInfo))
        infoBtn.accessibilityLabel = "How to earn belts"
        navigationItem.rightBarButtonItem = infoBtn
        for case let table as UITableView in view.subviews { beltTable = table }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The screen is a reused instance, so refresh every time it appears —
        // otherwise a belt just earned won't show until something forces a reload.
        // Default to the grade the child is currently set to.
        displayGrade = KidsTimeFunAppState.sharedState().gradeLevel
        gradeControl.selectedSegmentIndex = Int(displayGrade)
        beltTable?.reloadData()
    }

    @objc private func showBeltInfo() {
        let message = """
        Each activity has its own belts. Earn one by passing three rounds in a row:

        •  5 questions — no timer
        •  10 questions in 3 minutes
        •  10 questions in 2 minutes

        Each belt needs a higher score on every round:

        Yellow Belt — 50% correct
        Green Belt — 70% correct
        Red Belt — 90% correct
        Black Belt — 100% (a perfect run!)

        Miss a round? Just try it again. Belts are saved separately for each grade level.
        """
        let alert = UIAlertController(title: "How to Earn Belts", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default))
        present(alert, animated: true)
    }

    @objc private func gradeChanged(_ sender: UISegmentedControl) {
        displayGrade = Int32(sender.selectedSegmentIndex)
        beltTable?.reloadData()
        UIAccessibility.post(notification: .announcement,
                             argument: "Showing belts for \(gradeName(displayGrade))")
    }

    private func gradeName(_ g: Int32) -> String {
        gradeTitles.indices.contains(Int(g)) ? gradeTitles[Int(g)] : ""
    }

    // MARK: - Grade switcher as a floating section header

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        gradeControl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(gradeControl)
        let pad: CGFloat = isPad ? 16 : 10
        NSLayoutConstraint.activate([
            gradeControl.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: pad),
            gradeControl.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -pad),
            gradeControl.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            gradeControl.heightAnchor.constraint(equalToConstant: isPad ? 48 : 34)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 76 : 56
    }

    // MARK: - Rows: one per activity, showing the earned belt for the grade

    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Int(kNumberOfActivities)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 84 : 60
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "BeltRow"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ??
            UITableViewCell(style: .subtitle, reuseIdentifier: id)

        let act = Int32(indexPath.row)
        if act == kActMixed {
            // Solid teal (was a busy rainbow-stripe pattern that clashed with the rows).
            cell.backgroundColor = UIColor(red: 0.0, green: 0.6, blue: 0.6, alpha: 0.92)
        } else {
            cell.backgroundColor = activityColors[act] ?? .clear
        }
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = .boldSystemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18)
        cell.detailTextLabel?.textColor = .white
        cell.textLabel?.text = activityName(act)

        let earned = BeltProgressStore.shared.earnedBelt(grade: displayGrade, activity: act)
        if earned >= 0, Int(earned) < BeltProgressStore.beltNames.count {
            let beltName = BeltProgressStore.beltNames[Int(earned)]
            cell.imageView?.image = UIImage(named: beltName)
            cell.imageView?.contentMode = .scaleAspectFit
            cell.detailTextLabel?.text = beltName
            cell.accessibilityLabel = "\(activityName(act)), \(beltName)"
        } else {
            cell.imageView?.image = nil
            cell.detailTextLabel?.text = kStrNoBeltYet
            cell.accessibilityLabel = "\(activityName(act)), \(kStrNoBeltYet)"
        }

        cell.selectionStyle = .none
        cell.accessoryView = nil
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Rank Belts is a read-only overview — no drill-down.
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
