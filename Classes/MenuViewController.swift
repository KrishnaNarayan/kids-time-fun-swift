// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit
import QuartzCore

@objc(MenuViewController)
class MenuViewController: UIViewController {

    @IBOutlet var tellTimeButton: UIButton?
    @IBOutlet var setTimeButton: UIButton?
    @IBOutlet var elapsedTimeButton: UIButton?
    @IBOutlet var mixedModeButton: UIButton?
    @IBOutlet var tellTimeAfterButton: UIButton?
    @IBOutlet var tellTimeBeforeButton: UIButton?
    @IBOutlet var topScoresButton: UIButton?
    @IBOutlet var choiceActivityType: UISegmentedControl!
    @IBOutlet var clockView: ClockView!
    @IBOutlet var logoImageView: UIImageView?
    @IBOutlet var clipArtImageView: UIImageView?
    @IBOutlet var clipArtView: TransitionView?
    @IBOutlet var topScoresActVC: TopScoresActivitySelector!
    @IBOutlet var settingsVC: SettingsModalViewController!
    @IBOutlet var activityVC: ActivityViewController!

    private var clockTimer: Timer?
    private var clipArtTimer: Timer?
    private let playerChip = UIButton(type: .system)
    private static var didPresentPickerThisLaunch = false

    override func viewDidLoad() {
        super.viewDidLoad()
        installLegacyScaling(topAligned: true)
        title = kStrAppTitle
        edgesForExtendedLayout = []

        // Tappable player chip (avatar + name) as the title — taps to switch student.
        playerChip.addTarget(self, action: #selector(playerChipTapped), for: .touchUpInside)
        navigationItem.titleView = playerChip
        updatePlayerChip()

        let settingsBtn = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(settingsActivated))
        settingsBtn.accessibilityLabel = "Settings"
        navigationItem.rightBarButtonItem = settingsBtn
        let topScoresBtn = UIBarButtonItem(image: UIImage(systemName: "trophy"), style: .plain, target: self, action: #selector(topScoresButtonPressed(_:)))
        topScoresBtn.accessibilityLabel = kStrRankBelts
        navigationItem.leftBarButtonItem = topScoresBtn

        UIBarButtonItem.appearance().tintColor = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
        let backBtn = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: nil, action: nil)
        backBtn.accessibilityLabel = "Home"
        navigationItem.backBarButtonItem = backBtn

        // The Questions/Minutes selector is gone — round count and timing are now
        // decided by the belt-progression engine, not chosen on the main screen.
        choiceActivityType.isHidden = true

        // VoiceOver: give each activity launcher a clear spoken name, and hide the
        // purely decorative logo / rotating clip art from the rotor.
        let buttonLabels: [(UIButton?, String)] = [
            (tellTimeButton, "Tell Time"), (setTimeButton, "Set the Time"),
            (elapsedTimeButton, "Elapsed Time"), (mixedModeButton, "Mixed Practice"),
            (tellTimeAfterButton, "Time After"), (tellTimeBeforeButton, "Time Before"),
            (topScoresButton, "Top Scores")
        ]
        for (button, label) in buttonLabels { button?.accessibilityLabel = label }
        clipArtImageView?.isAccessibilityElement = false
        logoImageView?.isAccessibilityElement = false
        clipArtView?.isAccessibilityElement = false
        // (clockView is a ClockView; it already self-describes its time to VoiceOver.)
        if let cv = clipArtView {
            let clipArtFrame = CGRect(x: 0, y: 0, width: cv.frame.size.width, height: cv.frame.size.height)
            clipArtImageView?.frame = clipArtFrame
            logoImageView?.frame = clipArtFrame
            clipArtImageView?.contentMode = .scaleAspectFit
            logoImageView?.contentMode = .scaleAspectFit
            if let logo = logoImageView { cv.addSubview(logo) }
            clipArtTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeClipArt), userInfo: nil, repeats: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlayerChip()
        refreshClock()
        clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshClock), userInfo: nil, repeats: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // At launch, show "Who's Playing?" unless there's exactly one player (then
        // just use them). 0 players → add the first; 2+ → choose.
        guard !MenuViewController.didPresentPickerThisLaunch else { return }
        MenuViewController.didPresentPickerThisLaunch = true
        if ProfileStore.shared.profiles.count != 1 || ProfileStore.shared.activeProfile == nil {
            presentProfilePicker(animated: false)
        }
    }

    // MARK: - Player profiles

    private func updatePlayerChip() {
        let p = ProfileStore.shared.activeProfile
        playerChip.setTitle(p.map { "\($0.avatar)  \($0.name)  ▾" } ?? kStrAppTitle, for: .normal)
        playerChip.setTitleColor(UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1), for: .normal)
        playerChip.titleLabel?.font = .boldSystemFont(ofSize: 18)
        playerChip.accessibilityLabel = p.map { "Player: \($0.name). Double tap to switch player." } ?? kStrAppTitle
        playerChip.sizeToFit()
    }

    @objc private func playerChipTapped() {
        presentProfilePicker(animated: true)
    }

    private func presentProfilePicker(animated: Bool) {
        guard presentedViewController == nil else { return }
        let nav = UINavigationController(rootViewController: ProfileSelectViewController())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        clockTimer?.invalidate(); clockTimer = nil
    }

    deinit {
        clipArtTimer?.invalidate()
    }

    @objc func changeClipArt() {
        guard let cv = clipArtView, let civ = clipArtImageView else { return }
        let r = RandomInteger(range: Int(kClipArtFileRangeLow), to: Int(kClipArtFileRangeHigh))
        let name = String(format: kClipArtFileMask, r.randomInteger, kClipArtFileType)
        civ.image = UIImage(named: name)
        if let first = cv.subviews.first {
            cv.replaceSubview(first, withSubview: civ, transition: .push, direction: .fromLeft, duration: 0.10)
        }
    }

    @objc func refreshClock() {
        let cal = Calendar.autoupdatingCurrent
        let c = cal.dateComponents([.hour, .minute, .second], from: Date())
        clockView.hours = Float(c.hour ?? 0)
        clockView.minutes = Float(c.minute ?? 0)
        clockView.seconds = Float(c.second ?? 0)
        clockView.showSeconds = true; clockView.showClockAsAnalog = true
        clockView.showMinutesOffsetInHoursHand = true; clockView.showAMPM = false; clockView.showDayNight = false
        clockView.setNeedsDisplay()
    }

    @IBAction func tellTimeButtonPressed(_ sender: Any) {
        KidsTimeFunAppState.sharedState().activity = kActTellTime
        navigationController?.pushViewController(activityVC, animated: true)
    }

    @IBAction func setTimeButtonPressed(_ sender: Any) {
        KidsTimeFunAppState.sharedState().activity = kActSetTime
        navigationController?.pushViewController(activityVC, animated: true)
    }

    @IBAction func elapsedTimeButtonPressed(_ sender: Any) {
        KidsTimeFunAppState.sharedState().activity = kActElapsedTime
        navigationController?.pushViewController(activityVC, animated: true)
    }

    @IBAction func tellTimeAfterButtonPressed(_ sender: Any) {
        KidsTimeFunAppState.sharedState().activity = kActTimeAfter
        navigationController?.pushViewController(activityVC, animated: true)
    }

    @IBAction func tellTimeBeforeButtonPressed(_ sender: Any) {
        KidsTimeFunAppState.sharedState().activity = kActTimeBefore
        navigationController?.pushViewController(activityVC, animated: true)
    }

    @IBAction func mixedModeButtonPressed(_ sender: Any) {
        KidsTimeFunAppState.sharedState().activity = kActMixed
        navigationController?.pushViewController(activityVC, animated: true)
    }

    @IBAction @objc func topScoresButtonPressed(_ sender: Any) {
        navigationController?.pushViewController(topScoresActVC, animated: true)
    }

    @IBAction func setActivityType(_ sender: UISegmentedControl) {
        KidsTimeFunAppState.sharedState().activityType = Int32(sender.selectedSegmentIndex)
    }

    @IBAction @objc func settingsActivated() {
        guard navigationController?.topViewController == self else { return }
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @objc private func goHome() {}
}
