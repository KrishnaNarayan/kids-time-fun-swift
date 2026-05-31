// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(SettingsModalViewController)
class SettingsModalViewController: UIViewController {

    @IBOutlet private weak var numberOfQuestionsSlider: UISlider!
    @IBOutlet private weak var numberOfMinutesSlider: UISlider!
    @IBOutlet private weak var activityLevelChoiceControl: UISegmentedControl!
    @IBOutlet private weak var numberOfQuestionsLabel: UILabel!
    @IBOutlet private weak var numberOfMinutesLabel: UILabel!
    @IBOutlet private weak var activityLevelDescriptionDropDownView: UIView?
    @IBOutlet private weak var activityLevelLabel: UILabel?
    @IBOutlet private weak var activityLevelDescriptionLabel: UILabel!
    @IBOutlet private weak var playSoundDecider: UISwitch!

    private var isDirty = false
    private var numberOfQuestions = 0
    private var numberOfMinutes = 0
    private var activityLevel = 0
    private var playSoundInApplication = true

    private let minQ = 10, maxQ = 50, incQ = 10
    private let minM = 1, maxM = 5, incM = 1

    private let levelNames = ["Yellow Belt", "Green Belt", "Red Belt", "Black Belt"]
    private let levelDescriptions = [
        "YELLOW BELT\n2 answer choices\n30 minute time increments\n2 hour max math range",
        "GREEN BELT\n3 answer choices\n15 minute time increments\n4 hour max math range",
        "RED BELT\n4 answer choices\n5 minute time increments\n6 hour max math range",
        "BLACK BELT\n4 answer choices\n1 minute time increments\nNo max math range"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        installLegacyScaling()
        title = "Settings"

        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (docs as NSString).appendingPathComponent(kFileAppSettings)
        let dict = NSDictionary(contentsOfFile: path) as? [String: Any] ?? [:]

        isDirty = dict.isEmpty
        numberOfQuestions = Int((dict[kSettingsKeyNumberOfQuestions] as? NSNumber)?.int32Value ?? 0)
        if numberOfQuestions == 0 { numberOfQuestions = Int(kDefaultMaxNumberOfQuestions) }
        numberOfMinutes = Int((dict[kSettingsKeyNumberOfMinutes] as? NSNumber)?.int32Value ?? 0)
        if numberOfMinutes == 0 { numberOfMinutes = Int(kDefaultMaxTimeInSeconds) / 60 }
        activityLevel = Int((dict[kSettingsKeyActivityLevel] as? NSNumber)?.int32Value ?? 0)
        if activityLevel == 0 { activityLevel = Int(kDefaultActivityLevel) }
        playSoundInApplication = dict.isEmpty ? true : ((dict[kSettingsKeyPlaySound] as? NSNumber)?.boolValue ?? true)

        if UIImage.instancesRespond(to: #selector(UIImage.withRenderingMode(_:))) {
            ["Yellow Belt", "Green Belt", "Red Belt", "Black Belt"].enumerated().forEach { i, name in
                activityLevelChoiceControl.setImage(UIImage(named: name)?.withRenderingMode(.alwaysOriginal), forSegmentAt: i)
            }
        }

        numberOfQuestionsSlider.minimumValue = Float(minQ)
        numberOfQuestionsSlider.maximumValue = Float(maxQ)
        numberOfQuestionsSlider.isContinuous = true
        numberOfQuestionsSlider.value = Float(numberOfQuestions)
        numberOfMinutesSlider.minimumValue = Float(minM)
        numberOfMinutesSlider.maximumValue = Float(maxM)
        numberOfMinutesSlider.isContinuous = true
        numberOfMinutesSlider.value = Float(numberOfMinutes)
        activityLevelChoiceControl.selectedSegmentIndex = activityLevel
        numberOfQuestionsLabel.text = String(format: "Total Questions: %i", numberOfQuestions)
        numberOfMinutesLabel.text = String(format: "Total Minutes: %i", numberOfMinutes)
        playSoundDecider.isOn = playSoundInApplication
        updateLevelLabels()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)

        adjustChallengeLevelLayout()
    }

    private func adjustChallengeLevelLayout() {
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad

        guard let belt = activityLevelChoiceControl else { return }

        if isPad {
            // iPad: lift the belt selector out of the rainbow and anchor the existing
            // "Challenge Level" header just above it.
            if let sound = playSoundDecider, let header = findLabel(withText: "Challenge Level") {
                let headerH = header.frame.height
                let headerY = sound.frame.maxY + 24
                header.frame.origin.y = headerY
                belt.frame.origin.y = headerY + headerH + 24
            }
        } else {
            // iPhone: its XIB has no "Challenge Level" header — add one just above the
            // belt selector (leave the belt where it is; that layout is correct).
            let header = UILabel(frame: CGRect(x: belt.frame.minX, y: belt.frame.minY - 28,
                                               width: belt.frame.width, height: 24))
            header.text = "Challenge Level"
            header.font = .boldSystemFont(ofSize: 18)
            header.textColor = tint
            header.textAlignment = .center
            belt.superview?.addSubview(header)
        }

        // Make the belt description readable: centered text on a translucent panel.
        if let desc = activityLevelDescriptionLabel {
            desc.textAlignment = .center
            desc.backgroundColor = UIColor.white.withAlphaComponent(0.7)
            desc.layer.cornerRadius = 10
            desc.layer.masksToBounds = true
        }
    }

    private func findLabel(withText text: String, in root: UIView? = nil) -> UILabel? {
        let base = root ?? view
        for sub in base?.subviews ?? [] {
            if let label = sub as? UILabel, label.text == text { return label }
            if let found = findLabel(withText: text, in: sub) { return found }
        }
        return nil
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settingsDone(self)
    }

    @IBAction func maxNumberOfQuestionsChanged(_ sender: Any) {
        let v = Int(numberOfQuestionsSlider.value)
        numberOfQuestions = (v / incQ) * incQ
        numberOfQuestionsLabel.text = String(format: "Total Questions: %i", numberOfQuestions)
        isDirty = true
    }

    @IBAction func maxNumberOfMinutesChanged(_ sender: Any) {
        numberOfMinutes = Int(numberOfMinutesSlider.value / Float(incM)) * incM
        numberOfMinutesLabel.text = String(format: "Total Minutes: %i", numberOfMinutes)
        isDirty = true
    }

    @IBAction func activityLevelChoiceChanged(_ sender: Any) {
        isDirty = true
        activityLevel = activityLevelChoiceControl.selectedSegmentIndex
        updateLevelLabels()
    }

    @IBAction func playSound(_ sender: Any) {
        isDirty = true
        playSoundInApplication = playSoundDecider.isOn
    }

    @IBAction @objc func settingsDone(_ sender: Any) {
        guard isDirty else { return }
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (docs as NSString).appendingPathComponent(kFileAppSettings)
        let dict: NSDictionary = [
            kSettingsKeyNumberOfQuestions: NSNumber(value: numberOfQuestions),
            kSettingsKeyNumberOfMinutes: NSNumber(value: numberOfMinutes),
            kSettingsKeyActivityLevel: NSNumber(value: activityLevel),
            kSettingsKeyPlaySound: NSNumber(value: playSoundInApplication)
        ]
        dict.write(toFile: path, atomically: true)
        KidsTimeFunAppState.sharedState().readSettings()
    }

    private func updateLevelLabels() {
        guard activityLevel < levelNames.count else { return }
        activityLevelLabel?.text = levelNames[activityLevel]
        activityLevelDescriptionLabel.text = levelDescriptions[activityLevel]
    }
}
