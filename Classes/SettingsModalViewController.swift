// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(SettingsModalViewController)
class SettingsModalViewController: UIViewController {

    // Outlets kept from the legacy XIB. The sliders, belt segmented control and
    // their labels are no longer shown — we keep the references so we can hide
    // them and reuse their frames/superview as layout anchors.
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
    private var gradeLevel = 0
    private var playSoundInApplication = true

    // Grade level is the new single difficulty knob. Short visible titles keep
    // three buttons readable on iPhone; VoiceOver speaks the full grade name.
    private let gradeNames = [kStrFirstGrade, kStrSecondGrade, kStrThirdGrade]
    private let gradeShortTitles = ["1st", "2nd", "3rd"]
    private let gradeInfo = [kStrFirstGradeInfo, kStrSecondGradeInfo, kStrThirdGradeInfo]
    private var gradeButtons: [UIButton] = []
    private var soundButton: UIButton?
    private var gradeBottomY: CGFloat = 0   // bottom of the grade description, in content coords

    override func viewDidLoad() {
        super.viewDidLoad()
        installLegacyScaling()
        title = "Settings"

        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (docs as NSString).appendingPathComponent(kFileAppSettings)
        let dict = NSDictionary(contentsOfFile: path) as? [String: Any] ?? [:]

        // Grade level is per student — load it from the active profile.
        gradeLevel = Int(ProfileStore.shared.activeProfile?.gradeLevel ?? kDefaultGradeLevel)
        isDirty = false
        playSoundInApplication = dict.isEmpty ? true : ((dict[kSettingsKeyPlaySound] as? NSNumber)?.boolValue ?? true)
        playSoundDecider.isOn = playSoundInApplication

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let info = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(showHowItWorks))
        info.accessibilityLabel = "How it works, for grown-ups"
        navigationItem.rightBarButtonItem = info

        hideLegacyControls()
        installGradeSection()
        installSoundButton()
        addPrivacyLink()
    }

    @objc private func showHowItWorks() {
        let msg = """
        Kids Time Fun adapts to your child — it isn't random.

        •  Grade level sets the difficulty: 1st = hours & half-hours, 2nd = quarter-hours, 3rd = five-minute times.

        •  Belts are earned, not given. Your child passes rounds of questions to earn Yellow → Green → Red → Black, and each belt needs a higher score — so a belt means real, growing mastery.

        •  Smart practice: the app starts with varied questions, then notices which times your child misses and gives more practice on exactly those — improving where it counts instead of repeating what's already easy.

        •  Each child has their own profile, so progress is personal.

        Everything stays on this device — no accounts, no ads, nothing collected.
        """
        let alert = UIAlertController(title: "How Kids Time Fun Works", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Retire the old Questions / Minutes / Belt UI

    private func hideLegacyControls() {
        numberOfQuestionsSlider?.isHidden = true
        numberOfMinutesSlider?.isHidden = true
        activityLevelChoiceControl?.isHidden = true
        numberOfQuestionsLabel?.isHidden = true
        numberOfMinutesLabel?.isHidden = true
        activityLevelLabel?.isHidden = true
        activityLevelDescriptionDropDownView?.isHidden = true

        // The XIB also drew static tick labels (1…50) and "Total Questions" /
        // "Total Time" headers beneath the old sliders. Hide those leftovers.
        // Static leftover labels from the old Questions/Minutes/Belt layout. The
        // iPad XIB additionally bakes in "Challenge Level" and a "Yellow Belt"
        // caption; hide those too.
        let deadTexts: Set<String> = ["1", "2", "3", "4", "5", "10", "20", "30", "40", "50",
                                      "Total Questions", "Total Time", "Challenge Level", "Yellow Belt"]
        if let root = view.subviews.first {
            hideLabels(in: root, matching: deadTexts)
        }
    }

    private func hideLabels(in v: UIView, matching texts: Set<String>) {
        for sub in v.subviews {
            if let l = sub as? UILabel,
               texts.contains((l.text ?? "").trimmingCharacters(in: .whitespaces)) {
                l.isHidden = true
            }
            hideLabels(in: sub, matching: texts)
        }
    }

    // MARK: - Grade Level section

    private func installGradeSection() {
        guard let scaling = view.subviews.first as? LegacyScalingView else { return }
        let content = scaling.content
        let base = scaling.baseSize
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad

        // Lay the whole Grade Level section out in absolute base coordinates in the
        // upper area (above the Sound row), so header / buttons / info text always
        // line up regardless of the legacy XIB control positions.
        let sideMargin: CGFloat = isPad ? 90 : 24
        let rowW = base.width - sideMargin * 2
        let headerY = base.height * (isPad ? 0.20 : 0.16)
        let headerH: CGFloat = isPad ? 36 : 26
        let rowH: CGFloat = isPad ? 56 : 40
        let gapAfterHeader: CGFloat = isPad ? 14 : 8

        let header = UILabel(frame: CGRect(x: sideMargin, y: headerY, width: rowW, height: headerH))
        header.text = kStrGradeLevel
        header.font = .boldSystemFont(ofSize: isPad ? 28 : 20)
        header.textColor = tint
        header.textAlignment = .center
        content.addSubview(header)

        // Three selectable grade buttons.
        let rowFrame = CGRect(x: sideMargin, y: headerY + headerH + gapAfterHeader, width: rowW, height: rowH)
        let cells = (0..<gradeNames.count).map { i in
            (image: UIImage?.none, title: Optional(gradeShortTitles[i]), a11y: gradeNames[i])
        }
        gradeButtons = makeSelectableRow(frame: rowFrame, in: content, cells: cells)
        gradeButtons.forEach { $0.addTarget(self, action: #selector(gradeTapped(_:)), for: .touchUpInside) }
        styleSelection(gradeButtons, selected: gradeLevel)

        // Reuse the old description label for the increment info text, just below.
        if let desc = activityLevelDescriptionLabel {
            desc.isHidden = false
            desc.textAlignment = .center
            desc.backgroundColor = .clear
            desc.numberOfLines = 0
            desc.textColor = .darkGray
            desc.font = .systemFont(ofSize: isPad ? 21 : 15)
            desc.removeFromSuperview()
            content.addSubview(desc)
            // Box tall enough for the friendlier two/three-line descriptions.
            desc.frame = CGRect(x: sideMargin, y: rowFrame.maxY + (isPad ? 18 : 12),
                                width: rowW, height: isPad ? 80 : 72)
            gradeBottomY = desc.frame.maxY
            updateGradeInfo()
        }
    }

    /// First label with the given text anywhere under `root`.
    private func findLabel(withText text: String, in root: UIView) -> UILabel? {
        for sub in root.subviews {
            if let l = sub as? UILabel, l.text == text { return l }
            if let found = findLabel(withText: text, in: sub) { return found }
        }
        return nil
    }

    private func updateGradeInfo() {
        guard gradeInfo.indices.contains(gradeLevel) else { return }
        activityLevelDescriptionLabel.text = gradeInfo[gradeLevel]
    }

    @objc private func gradeTapped(_ sender: UIButton) {
        guard gradeNames.indices.contains(sender.tag) else { return }
        gradeLevel = sender.tag
        styleSelection(gradeButtons, selected: sender.tag)
        updateGradeInfo()
        isDirty = true
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

    // MARK: - Sound on/off (speaker icon button replacing the toggle switch)

    private func installSoundButton() {
        guard let scaling = view.subviews.first as? LegacyScalingView else { return }
        let content = scaling.content
        let base = scaling.baseSize
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        playSoundDecider?.isHidden = true

        // Build a centered "Sound" row a fixed distance BELOW the grade description,
        // so it can never collide with a two/three-line description on any screen
        // size (the iPad overlap bug).
        let rowY = gradeBottomY + (isPad ? 40 : 26)
        let side: CGFloat = isPad ? 56 : 40
        let gap: CGFloat = 12

        let soundLabel = findLabel(withText: "Sound", in: content) ?? UILabel()
        soundLabel.text = "Sound"
        soundLabel.font = .boldSystemFont(ofSize: isPad ? 24 : 18)
        soundLabel.textColor = tint
        soundLabel.removeFromSuperview()
        content.addSubview(soundLabel)
        soundLabel.sizeToFit()

        let button = UIButton(type: .system)
        button.tintColor = tint
        button.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: isPad ? 40 : 28, weight: .regular), forImageIn: .normal)
        button.addTarget(self, action: #selector(toggleSound), for: .touchUpInside)
        content.addSubview(button)

        let totalW = soundLabel.frame.width + gap + side
        let startX = (base.width - totalW) / 2
        soundLabel.frame = CGRect(x: startX, y: rowY + (side - soundLabel.frame.height) / 2,
                                  width: soundLabel.frame.width, height: soundLabel.frame.height)
        button.frame = CGRect(x: startX + soundLabel.frame.width + gap, y: rowY, width: side, height: side)

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

    // MARK: - Privacy link (parental gate before leaving the app)

    private static let privacyURL = URL(string: "https://krishnanarayan.github.io/kids-time-fun-swift/#privacy")!

    private func addPrivacyLink() {
        guard let scaling = view.subviews.first as? LegacyScalingView else { return }
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let base = scaling.baseSize
        let isPad = UIDevice.current.userInterfaceIdiom == .pad

        // Underlined, bold link text + a link icon so it clearly reads as tappable
        // on both iPhone and iPad (rather than looking like a plain caption).
        let link = UIButton(type: .system)
        let title = NSAttributedString(string: "Privacy Policy", attributes: [
            .font: UIFont.boldSystemFont(ofSize: isPad ? 22 : 17),
            .foregroundColor: tint,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        link.setAttributedTitle(title, for: .normal)
        link.tintColor = tint
        link.setImage(UIImage(systemName: "arrow.up.right.square"), for: .normal)
        link.setPreferredSymbolConfiguration(
            UIImage.SymbolConfiguration(pointSize: isPad ? 20 : 15, weight: .semibold), forImageIn: .normal)
        link.semanticContentAttribute = .forceRightToLeft   // icon sits after the text
        link.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        link.accessibilityTraits = .link
        link.accessibilityLabel = "Privacy Policy"
        link.accessibilityHint = "Opens the privacy policy in your web browser"
        link.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)

        // Center it within the green band near the bottom (lifted off the very edge,
        // especially on iPhone where it sat too low before).
        let w: CGFloat = isPad ? 340 : 240
        let h: CGFloat = isPad ? 50 : 40
        let centerY = base.height * (isPad ? 0.965 : 0.915)
        link.frame = CGRect(x: (base.width - w) / 2, y: centerY - h / 2, width: w, height: h)
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
        alert.addAction(UIAlertAction(title: "Open", style: .default) { [weak alert] _ in
            let answer = Int(alert?.textFields?.first?.text ?? "")
            if answer == a * b {
                UIApplication.shared.open(Self.privacyURL)
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Save

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settingsDone(self)
    }

    @IBAction @objc func settingsDone(_ sender: Any) {
        guard isDirty else { return }
        // Grade is saved on the active student's profile; sound stays app-wide.
        if let id = ProfileStore.shared.activeProfileID {
            ProfileStore.shared.setGrade(Int32(gradeLevel), for: id)
        }
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = (docs as NSString).appendingPathComponent(kFileAppSettings)
        let dict: NSDictionary = [kSettingsKeyPlaySound: NSNumber(value: playSoundInApplication)]
        dict.write(toFile: path, atomically: true)
        KidsTimeFunAppState.sharedState().readSettings()
    }

    // MARK: - Legacy XIB action stubs
    // These controls are hidden but their target-action wiring still lives in the
    // nib; keep no-op handlers so the connections never send to a missing selector.

    @IBAction func maxNumberOfQuestionsChanged(_ sender: Any) {}
    @IBAction func maxNumberOfMinutesChanged(_ sender: Any) {}
    @IBAction func activityLevelChoiceChanged(_ sender: Any) {}

    @IBAction func playSound(_ sender: Any) {
        playSoundInApplication = playSoundDecider.isOn
        updateSoundButton()
        isDirty = true
    }
}
