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
        addPrivacyLink()
    }

    private static let privacyURL = URL(string: "https://krishnanarayan.github.io/kids-time-fun-swift/#privacy")!

    private func addPrivacyLink() {
        guard let scaling = view.subviews.first as? LegacyScalingView else { return }
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let base = scaling.baseSize

        let link = UIButton(type: .system)
        link.setTitle("Privacy Policy", for: .normal)
        link.setTitleColor(tint, for: .normal)
        link.titleLabel?.font = .systemFont(ofSize: 14)
        link.tintColor = tint
        link.accessibilityHint = "Opens the privacy policy in your web browser"
        link.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)

        let w: CGFloat = 200, h: CGFloat = 30
        // Sit the link near the bottom of the canvas; nudge it a little lower on
        // iPhone where there is extra room beneath the belt description.
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let bottomMargin: CGFloat = isPad ? 8 : -10
        link.frame = CGRect(x: (base.width - w) / 2, y: base.height - h - bottomMargin, width: w, height: h)
        scaling.content.addSubview(link)
    }

    @objc private func openPrivacyPolicy() {
        // Parental gate: the privacy policy opens in Safari (leaves the app), so
        // require a simple grown-up check first to satisfy Apple's Kids Category
        // rules for links out of the app.
        let a = Int.random(in: 6...9)
        let b = Int.random(in: 6...9)
        let alert = UIAlertController(
            title: "Ask a Grown-Up",
            message: "To open the privacy policy in your browser, please answer:\n\nWhat is \(a) × \(b)?",
            preferredStyle: .alert)
        alert.addTextField { tf in
            tf.keyboardType = .numberPad
            tf.placeholder = "Answer"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Open", style: .default) { [weak self, weak alert] _ in
            let answer = Int(alert?.textFields?.first?.text ?? "")
            if answer == a * b {
                UIApplication.shared.open(Self.privacyURL)
            }
        })
        present(alert, animated: true)
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

        // Move the belt description into the rainbow's white center (plain text).
        // Reparent to the scaling container so we can position it in absolute
        // content coordinates rather than relative to the overflowing dropdown.
        if let desc = activityLevelDescriptionLabel,
           let scaling = view.subviews.first as? LegacyScalingView {
            desc.textAlignment = .center
            desc.backgroundColor = .clear
            desc.numberOfLines = 0
            desc.removeFromSuperview()
            scaling.content.addSubview(desc)
            let base = scaling.baseSize
            let w = base.width * 0.85
            desc.frame = CGRect(x: (base.width - w) / 2, y: base.height * 0.78, width: w, height: 120)
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
