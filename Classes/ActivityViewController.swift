// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit
import QuartzCore

@objc(ActivityViewController)
class ActivityViewController: UIViewController, DismissResultDelegate, DismissActivityDelegate, UIGestureRecognizerDelegate {

    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0   // earned belt (-1 none … 3 black) — drives the header image
    var gradeLevel: Int32 = 0      // difficulty knob passed to the generators
    var maxQuestions: Int32 = 0
    var maxSeconds: Int32 = 0
    // The belt-ladder position is persisted in BeltProgressStore, so it resumes
    // across leaving/re-entering the activity. After a round we either continue to
    // the next/repeated round or, on earning a belt, return to the menu.
    private var sessionContinues = false
    // Guards against the round ending more than once. A timed round can hit its
    // time limit AND its question limit at nearly the same moment (in-flight answer
    // feedback); without this the results screen could be pushed twice / over an
    // alert, freezing the UI.
    private var roundFinished = false
    private(set) var currentQuestion: Int32 = 1
    private(set) var elapsedSeconds: Int32 = 0
    private(set) var questionsAsked: Int32 = 1
    private(set) var questionsAttempted: Int32 = 0
    private(set) var rightAnswers: Int32 = 0
    private(set) var wrongAnswers: Int32 = 0
    private(set) var secondsTaken: Int32 = 0
    private(set) var percentScore: Float = 0
    private(set) var activityState: Int32 = 0

    @IBOutlet var transView: TransitionView!
    @IBOutlet var composite: UIView!
    @IBOutlet var header: ActivityHeaderView!
    @IBOutlet var content: UIView!
    @IBOutlet var activityBG: UIImageView!

    var startTime: Date?
    var endTime: Date?
    var etvc: ElapsedTimeViewController?
    var stvc: SetTimeViewController?
    var ttvc: TellTimeViewController?

    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        startTime = Date()
        // A custom left bar button makes UIKit disable the interactive swipe-back
        // gesture — which otherwise fires when dragging a clock hand near the edge.
        navigationItem.hidesBackButton = true
        let homeBtn = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(goHome(_:)))
        homeBtn.accessibilityLabel = "Home"
        navigationItem.leftBarButtonItem = homeBtn
        activityBG.contentMode = .scaleAspectFill
        activityBG.clipsToBounds = true
    }


    // Defer system edge gestures so dragging a clock hand to the screen edge does
    // not trigger swipe-back / dock / control-center instead of moving the hand.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard composite != nil else { return }
        // The XIB content is a fixed design size; aspect-fit it into the safe area
        // so the score header (top) and answers (bottom) are fully visible.
        let base = UIDevice.current.userInterfaceIdiom == .pad
            ? CGSize(width: 768, height: 1024)
            : CGSize(width: 320, height: 568)
        let safe = view.bounds.inset(by: view.safeAreaInsets)
        guard safe.width > 0, safe.height > 0 else { return }
        let scale = min(safe.width / base.width, safe.height / base.height)
        composite.transform = .identity
        composite.bounds = CGRect(origin: .zero, size: base)
        composite.transform = CGAffineTransform(scaleX: scale, y: scale)
        composite.center = CGPoint(x: safe.midX, y: safe.midY)
    }

    override func viewWillAppear(_ animated: Bool) {
        let state = KidsTimeFunAppState.sharedState()
        activity = state.activity
        gradeLevel = state.gradeLevel
        // Reset the round clock here (not viewDidLoad) — this VC is a reused outlet
        // instance, so each round must start its own timing.
        startTime = Date()

        // The belt-progression engine decides this round's shape (how many
        // questions, whether it's timed, the time limit) for the current ladder
        // position, and what belt the child is working toward. The header shows
        // the belt already earned.
        let plan = BeltProgressStore.shared.roundPlan(grade: gradeLevel, activity: activity)
        activityType = plan.activityType
        maxQuestions = plan.questions
        maxSeconds = plan.seconds
        activityLevel = plan.earnedBelt
        // Mirror onto shared state so the header, timer, and result screen agree.
        state.activityType = plan.activityType
        state.maxQuestions = plan.questions
        state.maxTimeInSeconds = plan.seconds
        state.activityLevel = plan.earnedBelt

        currentQuestion = 1; elapsedSeconds = 0; questionsAsked = 1
        questionsAttempted = 0; rightAnswers = 0; wrongAnswers = 0; secondsTaken = 0
        roundFinished = false

        if state.activityType == kActTypeTimed {
            header.countdownTimer = state.maxTimeInSeconds
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            header.setNeedsDisplay()
        }

        header.right = rightAnswers; header.wrong = wrongAnswers
        header.current = currentQuestion; header.total = maxQuestions
        header.showTimer = state.activityType == kActTypeTimed
        header.activityLevel = activityLevel; header.showTotal = true
        header.setNeedsDisplay()
        loadActivity(Int32(activity))
        // Dragging clock hands near the left edge would otherwise trigger the
        // swipe-back gesture and pop to the menu. Disable it during the activity.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Bulletproof: take over the interactive-pop gesture delegate and deny it,
        // so dragging a clock hand can never start a swipe-back to the menu.
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        setNeedsUpdateOfScreenEdgesDeferringSystemGestures()
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // Deny the swipe-back while an activity is on screen.
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            return false
        }
        return true
    }

    override func viewWillDisappear(_ animated: Bool) {
        if KidsTimeFunAppState.sharedState().activityType == kActTypeTimed {
            timer?.invalidate(); timer = nil
        }
        content.subviews.forEach { $0.removeFromSuperview() }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        super.viewWillDisappear(true)
    }


    func loadActivity(_ thisActivity: Int32) {
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        switch thisActivity {
        case kActTellTime:
            activityBG.image = UIImage(named: kBGTellTime)
            let vc = TellTimeViewController(nibName: isIPad ? kiPadNibTellTime : kNibTellTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.gradeLevel = gradeLevel; vc.timeOffset = 0
            vc.delegate = self; navigationItem.title = kStrTellTime
            ttvc = vc; content.addSubview(vc.view)
        case kActSetTime:
            activityBG.image = UIImage(named: kBGSetTime)
            let vc = SetTimeViewController(nibName: isIPad ? kiPadNibSetTime : kNibSetTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.gradeLevel = gradeLevel; vc.timeOffset = 0
            vc.delegate = self; navigationItem.title = kStrSetTime
            stvc = vc; content.addSubview(vc.view)
        case kActTimeBefore:
            activityBG.image = UIImage(named: kBGTimeBefore)
            let vc = TellTimeViewController(nibName: isIPad ? kiPadNibTellTime : kNibTellTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.gradeLevel = gradeLevel; vc.timeOffset = -1
            vc.delegate = self; navigationItem.title = kStrTimeBefore
            ttvc = vc; content.addSubview(vc.view)
        case kActTimeAfter:
            activityBG.image = UIImage(named: kBGTimeAfter)
            let vc = TellTimeViewController(nibName: isIPad ? kiPadNibTellTime : kNibTellTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.gradeLevel = gradeLevel; vc.timeOffset = 1
            vc.delegate = self; navigationItem.title = kStrTimeAfter
            ttvc = vc; content.addSubview(vc.view)
        case kActElapsedTime:
            activityBG.image = UIImage(named: kBGElapsedTime)
            let vc = ElapsedTimeViewController(nibName: isIPad ? kiPadNibElapsedTime : kNibElapsedTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.gradeLevel = gradeLevel; vc.timeOffset = 1
            vc.delegate = self; navigationItem.title = kStrElapsedTime
            etvc = vc; content.addSubview(vc.view)
        case kActMixed:
            activityBG.image = UIImage(named: kBGMixed)
            loadActivity(Int32(Int.random(in: 0...4)))
        default: break
        }
        transView.addSubview(composite)
    }

    private func loadNextActivity(sender: AnyObject) {
        // If the round already ended (e.g. the timer ran out), ignore any trailing
        // answer-feedback callbacks so we never load another question or push the
        // results screen a second time.
        guard !roundFinished else { return }
        currentQuestion += 1
        if (sender as? TellTimeViewController)?.isRight == true ||
           (sender as? ElapsedTimeViewController)?.isRight == true ||
           (sender as? SetTimeViewController)?.isRight == true {
            rightAnswers += 1
        } else {
            wrongAnswers += 1
        }
        header.right = rightAnswers; header.wrong = wrongAnswers
        header.current = currentQuestion; header.total = maxQuestions; header.showTotal = true
        header.setNeedsDisplay()

        let state = KidsTimeFunAppState.sharedState()
        state.questionNumber = currentQuestion; state.questionsRight = rightAnswers; state.questionsWrong = wrongAnswers

        // Every belt-ladder round has a fixed number of questions (10 or 20). A
        // timed round simply adds a time limit on top — it ends at the question
        // count OR when the countdown hits zero (handled in countDown), whichever
        // comes first. So the round-end test is the same for both modes.
        if currentQuestion <= maxQuestions {
            questionsAsked += 1; questionsAttempted += 1
            content.subviews.first?.removeFromSuperview()
            let next = activity == kActMixed ? Int32(Int.random(in: 0...4)) : activity
            loadActivity(next)
            composite.layoutIfNeeded()
            if let oldView = transView.subviews.indices.contains(1) ? transView.subviews[1] : nil {
                transView.replaceSubview(oldView, withSubview: composite, transition: .push, direction: .fromRight, duration: 0.25)
            }
        } else {
            finishRound()
        }
    }

    /// End the current round exactly once and show the results.
    private func finishRound() {
        guard !roundFinished else { return }
        roundFinished = true
        timer?.invalidate(); timer = nil
        loadResultsView(sender: self)
    }

    func loadResultsView(sender: AnyObject) {
        if KidsTimeFunAppState.sharedState().activityType == kActTypeTimed {
            timer?.invalidate(); timer = nil
        }
        endTime = Date()
        title = kStrResult
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let vc = ResultViewController(nibName: isIPad ? kiPadNibResult : kNibResult, bundle: nil)
        vc.delegate = self
        vc.rightAnswers = rightAnswers; vc.wrongAnswers = wrongAnswers
        let answered = rightAnswers + wrongAnswers
        vc.totalQuestions = answered
        let percent: Float = answered > 0 ? Float(rightAnswers) / Float(answered) : 0
        vc.percentScore = percent
        vc.timeTakenInSeconds = Int32(endTime?.timeIntervalSince(startTime ?? Date()) ?? 0)

        // Feed the score into the belt engine and let the result screen announce
        // whether the child advances to the next round, repeats this one, or earned
        // a belt. Continuing keeps the same session going (next/repeat round);
        // earning a belt (or mastering) ends the session back at the menu.
        let outcome = BeltProgressStore.shared.evaluateRound(grade: gradeLevel, activity: activity, percent: percent)
        vc.outcomeMessage = outcome.message
        vc.awardedBeltImageName = outcome.awardedBeltImageName
        vc.canContinue = outcome.sessionContinues
        sessionContinues = outcome.sessionContinues
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func countDown() {
        guard KidsTimeFunAppState.sharedState().activityType == kActTypeTimed, !roundFinished else { return }
        if header.countdownTimer <= 0 {
            // Time's up — end the round cleanly and go straight to the results. (We
            // deliberately don't pop up a blocking alert here: the round's in-flight
            // answer feedback could otherwise keep advancing questions underneath it
            // and then push the results a second time, freezing the screen.)
            finishRound()
        } else {
            header.countdownTimer -= 1
            header.setNeedsDisplay()
        }
    }

    @objc private func goHome(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: - DismissResultDelegate
    func didDismissResult(_ sender: Any) {
        // Continue to the next (or repeated) round — the new position is already
        // persisted, so popping back to this controller re-reads it. If a belt was
        // earned/mastered the ladder reset, so return to the menu instead.
        if sessionContinues {
            navigationController?.popToViewController(self, animated: true)
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - DismissActivityDelegate
    func didDismissActivity(_ sender: Any) {
        if navigationController?.topViewController == self { loadNextActivity(sender: sender as AnyObject) }
    }
}
