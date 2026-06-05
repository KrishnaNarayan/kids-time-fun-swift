// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit
import MessageUI
import QuartzCore

@objc(MenuViewController)
class MenuViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet var tellTimeButton: UIButton?
    @IBOutlet var setTimeButton: UIButton?
    @IBOutlet var elapsedTimeButton: UIButton?
    @IBOutlet var mixedModeButton: UIButton?
    @IBOutlet var tellTimeAfterButton: UIButton?
    @IBOutlet var tellTimeBeforeButton: UIButton?
    @IBOutlet var topScoresButton: UIButton?
    @IBOutlet var helpButton: UIButton?
    @IBOutlet var tellAFriendButton: UIButton?
    @IBOutlet var choiceActivityType: UISegmentedControl!
    @IBOutlet var clockView: ClockView!
    @IBOutlet var logoImageView: UIImageView?
    @IBOutlet var clipArtImageView: UIImageView?
    @IBOutlet var clipArtView: TransitionView?
    @IBOutlet var topScoresActVC: TopScoresActivitySelector!
    @IBOutlet var settingsVC: SettingsModalViewController!
    @IBOutlet var helpVC: HelpViewController!
    @IBOutlet var activityVC: ActivityViewController!

    private var clockTimer: Timer?
    private var clipArtTimer: Timer?
    private var message: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        installLegacyScaling(topAligned: true)
        title = kStrAppTitle
        edgesForExtendedLayout = []

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

        // Hide defunct app-launcher buttons (tags 700–706)
        for tag in 700...707 {
            view.viewWithTag(tag)?.isHidden = true
        }

        // The Questions/Minutes selector is gone — round count and timing are now
        // decided by the belt-progression engine, not chosen on the main screen.
        choiceActivityType.isHidden = true

        // VoiceOver: give each activity launcher a clear spoken name, and hide the
        // purely decorative logo / rotating clip art from the rotor.
        let buttonLabels: [(UIButton?, String)] = [
            (tellTimeButton, "Tell Time"), (setTimeButton, "Set the Time"),
            (elapsedTimeButton, "Elapsed Time"), (mixedModeButton, "Mixed Practice"),
            (tellTimeAfterButton, "Time After"), (tellTimeBeforeButton, "Time Before"),
            (topScoresButton, "Top Scores"), (helpButton, "Help"),
            (tellAFriendButton, "Tell a Friend")
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
        refreshClock()
        clockTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshClock), userInfo: nil, repeats: true)
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

    @IBAction func helpButtonPressed(_ sender: Any) {
        navigationController?.pushViewController(helpVC, animated: true)
    }

    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            displayComposerSheet()
        } else {
            launchMailAppOnDevice()
        }
    }

    @IBAction func setActivityType(_ sender: UISegmentedControl) {
        KidsTimeFunAppState.sharedState().activityType = Int32(sender.selectedSegmentIndex)
    }

    @IBAction @objc func settingsActivated() {
        guard navigationController?.topViewController == self else { return }
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @IBAction func launchApp(_ sender: UIButton) {
        guard let path = Bundle.main.path(forResource: "AppLaunchInfo", ofType: "plist"),
              let apps = NSArray(contentsOfFile: path) as? [[String: String]] else { return }
        let idx = sender.tag - 700
        guard idx >= 0 && idx < apps.count else { return }
        let app = apps[idx]
        guard let launchURLStr = app["AppLaunchURL"],
              let storeURLStr = app["AppStoreURL"],
              let launchURL = URL(string: launchURLStr),
              let storeURL = URL(string: storeURLStr) else { return }
        if UIApplication.shared.canOpenURL(launchURL) {
            UIApplication.shared.open(launchURL)
        } else {
            UIApplication.shared.open(storeURL)
        }
    }

    @objc private func goHome() {}

    func displayComposerSheet() {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Kids Time Fun App")
        picker.setMessageBody("Please try this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766", isHTML: false)
        present(picker, animated: true)
    }

    func launchMailAppOnDevice() {
        let base = "mailto:?subject=Learn To Tell Time--Kids iPhone/iPod/iPad App!&body=Please try this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766"
        guard let url = URL(string: base) else { return }
        UIApplication.shared.open(url)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                                didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled: message = "User cancelled"
        case .saved:     message = "Your information saved successfully"
        case .sent:      message = "Your friends were informed about this application"
        case .failed:    message = "Sorry, I couldn't inform your friend. Try again"
        default:         message = "Result: not sent"
        }
        dismiss(animated: true) {
            let alert = UIAlertController(title: "Tell A Friend", message: self.message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
