import UIKit
import QuartzCore

class ActivityViewController: UIViewController, DismissResultDelegate, DismissActivityDelegate {

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
        let homeBtn = UIBarButtonItem(image: UIImage(named: kImgHome), style: .plain, target: self, action: #selector(goHome(_:)))
        navigationItem.backBarButtonItem = homeBtn
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
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        if KidsTimeFunAppState.sharedState().activityType == kActTypeTimed {
            timer?.invalidate(); timer = nil
        }
        content.subviews.forEach { $0.removeFromSuperview() }
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
                transView.replaceSubview(oldView, withSubview: composite, transition: kCATransitionPush, direction: kCATransitionFromRight, duration: 0.25)
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
        vc.totalQuestions = rightAnswers + wrongAnswers
        vc.percentScore = Float(rightAnswers) / Float(rightAnswers + wrongAnswers)
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
        if header.countdownTimer <= 0 && (navigationController?.topViewController == self || !transView.isTransitioning) {
            timer?.invalidate(); timer = nil
            let alert = UIAlertController(title: "Time is up!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            if navigationController?.topViewController == self { loadResultsView(sender: self) }
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
