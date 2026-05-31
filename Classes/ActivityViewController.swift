import UIKit
import QuartzCore

@objc(ActivityViewController)
class ActivityViewController: UIViewController, DismissResultDelegate, DismissActivityDelegate, UIGestureRecognizerDelegate {

    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var maxQuestions: Int32 = 0
    var maxSeconds: Int32 = 0
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(goHome(_:)))
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
        activity = state.activity; activityType = state.activityType; activityLevel = state.activityLevel
        maxQuestions = state.maxQuestions; maxSeconds = state.maxTimeInSeconds
        currentQuestion = 1; elapsedSeconds = 0; questionsAsked = 1
        questionsAttempted = 0; rightAnswers = 0; wrongAnswers = 0; secondsTaken = 0

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
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.timeOffset = 0
            vc.delegate = self; navigationItem.title = kStrTellTime
            ttvc = vc; content.addSubview(vc.view)
        case kActSetTime:
            activityBG.image = UIImage(named: kBGSetTime)
            let vc = SetTimeViewController(nibName: isIPad ? kiPadNibSetTime : kNibSetTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.timeOffset = 0
            vc.delegate = self; navigationItem.title = kStrSetTime
            stvc = vc; content.addSubview(vc.view)
        case kActTimeBefore:
            activityBG.image = UIImage(named: kBGTimeBefore)
            let vc = TellTimeViewController(nibName: isIPad ? kiPadNibTellTime : kNibTellTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.timeOffset = -1
            vc.delegate = self; navigationItem.title = kStrTimeBefore
            ttvc = vc; content.addSubview(vc.view)
        case kActTimeAfter:
            activityBG.image = UIImage(named: kBGTimeAfter)
            let vc = TellTimeViewController(nibName: isIPad ? kiPadNibTellTime : kNibTellTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.timeOffset = 1
            vc.delegate = self; navigationItem.title = kStrTimeAfter
            ttvc = vc; content.addSubview(vc.view)
        case kActElapsedTime:
            activityBG.image = UIImage(named: kBGElapsedTime)
            let vc = ElapsedTimeViewController(nibName: isIPad ? kiPadNibElapsedTime : kNibElapsedTime, bundle: nil)
            vc.activity = thisActivity; vc.activityType = activityType; vc.activityLevel = activityLevel; vc.timeOffset = 1
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

        let numbered = state.activityType == kActTypeNumbered && currentQuestion <= maxQuestions
        let timed = state.activityType == kActTypeTimed && secondsTaken <= maxSeconds
        if numbered || timed {
            questionsAsked += 1; questionsAttempted += 1
            content.subviews.first?.removeFromSuperview()
            let next = activity == kActMixed ? Int32(Int.random(in: 0...4)) : activity
            loadActivity(next)
            composite.layoutIfNeeded()
            if let oldView = transView.subviews.indices.contains(1) ? transView.subviews[1] : nil {
                transView.replaceSubview(oldView, withSubview: composite, transition: .push, direction: .fromRight, duration: 0.25)
            }
        } else {
            loadResultsView(sender: self)
        }
    }

    func loadResultsView(sender: AnyObject) {
        if KidsTimeFunAppState.sharedState().activityType == kActTypeTimed {
            timer?.invalidate(); timer = nil
        }
        endTime = Date()
        title = kStrResult
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let vc = ResultViewController(nibName: isIPad ? kiPadNibResult : kNibResult, bundle: nil)
        vc.rightAnswers = rightAnswers; vc.wrongAnswers = wrongAnswers
        let answered = rightAnswers + wrongAnswers
        vc.totalQuestions = answered
        vc.percentScore = answered > 0 ? Float(rightAnswers) / Float(answered) : 0
        vc.timeTakenInSeconds = activityType == kActTypeTimed ? maxSeconds : Int32(endTime?.timeIntervalSince(startTime ?? Date()) ?? 0)
        navigationController?.pushViewController(vc, animated: true)
    }

    func loadTopScoresView(sender: AnyObject) {
        let vc = TopScoresSingleDetailViewController(activity: activity, andType: activityType, andLevel: activityLevel, withNibName: "TopScoresSingleDetailView", bundle: nil)
        title = kStrTopScores
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func countDown() {
        guard KidsTimeFunAppState.sharedState().activityType == kActTypeTimed else { return }
        if header.countdownTimer <= 0 {
            timer?.invalidate(); timer = nil
            guard navigationController?.topViewController == self else { return }
            let alert = UIAlertController(title: "Time is up!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.loadResultsView(sender: self)
            })
            present(alert, animated: true)
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
        if navigationController?.topViewController == self { loadTopScoresView(sender: self) }
    }

    // MARK: - DismissActivityDelegate
    func didDismissActivity(_ sender: Any) {
        if navigationController?.topViewController == self { loadNextActivity(sender: sender as AnyObject) }
    }
}
