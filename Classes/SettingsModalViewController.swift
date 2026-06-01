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

    // Discrete choices that replace the old continuous sliders.
    private let questionOptions = [10, 20, 30, 40, 50]
    private let minuteOptions = [1, 2, 3, 4, 5]
    private var questionButtons: [UIButton] = []
    private var minuteButtons: [UIButton] = []
    private var beltButtons: [UIButton] = []
    private var soundButton: UIButton?

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

        installDiscretePickers()
        installSoundButton()
        adjustChallengeLevelLayout()
        installBeltButtons()   // after adjustChallengeLevelLayout: belt frame is final
        addPrivacyLink()
    }

    // MARK: - Discrete pickers (button rows replacing the continuous sliders)

    private func installDiscretePickers() {
        // Snap any stored value to the nearest allowed option so the saved value
        // is always one of the discrete choices.
        if !questionOptions.contains(numberOfQuestions) {
            numberOfQuestions = questionOptions.min(by: { abs($0 - numberOfQuestions) < abs($1 - numberOfQuestions) }) ?? 30
        }
        if !minuteOptions.contains(numberOfMinutes) {
            numberOfMinutes = minuteOptions.min(by: { abs($0 - numberOfMinutes) < abs($1 - numberOfMinutes) }) ?? 1
        }
        numberOfQuestionsLabel.text = String(format: "Total Questions: %i", numberOfQuestions)
        numberOfMinutesLabel.text = String(format: "Total Minutes: %i", numberOfMinutes)

        if let slider = numberOfQuestionsSlider, let parent = slider.superview {
            slider.isHidden = true
            let cells = questionOptions.map { (image: UIImage?.none, title: Optional("\($0)"), a11y: "\($0) questions") }
            questionButtons = makeSelectableRow(frame: slider.frame, in: parent, cells: cells)
            questionButtons.forEach { $0.addTarget(self, action: #selector(questionTapped(_:)), for: .touchUpInside) }
            styleSelection(questionButtons, selected: questionOptions.firstIndex(of: numberOfQuestions) ?? 2)
        }
        if let slider = numberOfMinutesSlider, let parent = slider.superview {
            slider.isHidden = true
            let cells = minuteOptions.map { (image: UIImage?.none, title: Optional("\($0)"),
                                             a11y: $0 == 1 ? "1 minute" : "\($0) minutes") }
            minuteButtons = makeSelectableRow(frame: slider.frame, in: parent, cells: cells)
            minuteButtons.forEach { $0.addTarget(self, action: #selector(minuteTapped(_:)), for: .touchUpInside) }
            styleSelection(minuteButtons, selected: minuteOptions.firstIndex(of: numberOfMinutes) ?? 0)
        }

        // The original XIB drew static tick labels (10 20 30 40 50 / 1 2 3 4 5)
        // beneath the sliders. They're now redundant — hide them.
        if let content = numberOfQuestionsSlider?.superview {
            let tickTexts = Set((questionOptions + minuteOptions).map { "\($0)" })
            for case let label as UILabel in content.subviews
            where tickTexts.contains((label.text ?? "").trimmingCharacters(in: .whitespaces)) {
                label.isHidden = true
            }
        }
    }

    private func installBeltButtons() {
        guard let belt = activityLevelChoiceControl, let parent = belt.superview else { return }
        belt.isHidden = true   // keep the XIB control for its frame/wiring, but show buttons
        let cells = levelNames.map { (image: UIImage(named: $0), title: String?.none, a11y: $0) }
        beltButtons = makeSelectableRow(frame: belt.frame, in: parent, cells: cells)
        beltButtons.forEach { $0.addTarget(self, action: #selector(beltTapped(_:)), for: .touchUpInside) }
        styleSelection(beltButtons, selected: activityLevel)
    }

    /// Build a horizontal row of selectable buttons (radio style) filling `frame`.
    /// Each is an independent VoiceOver button so the user can swipe between them
    /// and double-tap to choose.
    private func makeSelectableRow(frame: CGRect, in parent: UIView,
                                   cells: [(image: UIImage?, title: String?, a11y: String)]) -> [UIButton] {
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let n = cells.count
        let gap: CGFloat = 4
        let w = (frame.width - gap * CGFloat(n - 1)) / CGFloat(n)
        var buttons: [UIButton] = []
        for (i, cell) in cells.enumerated() {
            let b = UIButton(type: .custom)
            b.frame = CGRect(x: frame.minX + CGFloat(i) * (w + gap), y: frame.minY, width: w, height: frame.height)
            if let img = cell.image {
                b.setImage(img.withRenderingMode(.alwaysOriginal), for: .normal)
                b.imageView?.contentMode = .scaleAspectFit
                b.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
            }
            if let title = cell.title {
                b.setTitle(title, for: .normal)
                b.setTitleColor(tint, for: .normal)
                b.titleLabel?.font = .boldSystemFont(ofSize: isPad ? 22 : 16)
            }
            b.accessibilityLabel = cell.a11y
            b.layer.cornerRadius = 8
            b.layer.borderColor = tint.cgColor
            b.tag = i
            parent.addSubview(b)
            buttons.append(b)
        }
        return buttons
    }

    /// Highlight the chosen button and mark it `.selected` for VoiceOver.
    private func styleSelection(_ buttons: [UIButton], selected: Int) {
        for (i, b) in buttons.enumerated() {
            let on = i == selected
            b.layer.borderWidth = on ? 2 : 0
            b.backgroundColor = on ? UIColor(red: 0.80, green: 0.90, blue: 1.0, alpha: 1) : .clear
            b.accessibilityTraits = on ? [.button, .selected] : .button
        }
    }

    @objc private func questionTapped(_ sender: UIButton) {
        guard questionOptions.indices.contains(sender.tag) else { return }
        numberOfQuestions = questionOptions[sender.tag]
        numberOfQuestionsLabel.text = String(format: "Total Questions: %i", numberOfQuestions)
        styleSelection(questionButtons, selected: sender.tag)
        isDirty = true
    }

    @objc private func minuteTapped(_ sender: UIButton) {
        guard minuteOptions.indices.contains(sender.tag) else { return }
        numberOfMinutes = minuteOptions[sender.tag]
        numberOfMinutesLabel.text = String(format: "Total Minutes: %i", numberOfMinutes)
        styleSelection(minuteButtons, selected: sender.tag)
        isDirty = true
    }

    @objc private func beltTapped(_ sender: UIButton) {
        guard levelNames.indices.contains(sender.tag) else { return }
        activityLevel = sender.tag
        styleSelection(beltButtons, selected: sender.tag)
        updateLevelLabels()
        isDirty = true
    }

    // MARK: - Sound on/off (speaker icon button replacing the toggle switch)

    private func installSoundButton() {
        guard let sw = playSoundDecider, let parent = sw.superview else { return }
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let button = UIButton(type: .system)
        button.tintColor = tint
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: isPad ? 40 : 28, weight: .regular), forImageIn: .normal)
        let side: CGFloat = isPad ? 56 : 40
        // Left-align with the switch, vertically centered on it.
        button.frame = CGRect(x: sw.frame.minX, y: sw.frame.midY - side / 2, width: side, height: side)
        button.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        sw.isHidden = true
        parent.addSubview(button)
        soundButton = button
        updateSoundButton()
    }

    @objc private func toggleSound() {
        playSoundInApplication.toggle()
        playSoundDecider?.isOn = playSoundInApplication
        isDirty = true
        updateSoundButton()
    }

    private func updateSoundButton() {
        let on = playSoundInApplication
        soundButton?.setImage(UIImage(systemName: on ? "speaker.wave.2.fill" : "speaker.slash.fill"), for: .normal)
        soundButton?.accessibilityLabel = on ? "Sound On" : "Sound Off"
        soundButton?.accessibilityHint = on ? "Double tap to turn sound off" : "Double tap to turn sound on"
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

    // Retained for the XIB switch action connection; the visible control is now
    // the speaker button (see toggleSound). The switch itself is hidden.
    @IBAction func playSound(_ sender: Any) {
        isDirty = true
        playSoundInApplication = playSoundDecider.isOn
        updateSoundButton()
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
