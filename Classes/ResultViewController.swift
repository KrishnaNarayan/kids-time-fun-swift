import UIKit

@objc protocol DismissResultDelegate: AnyObject {
    func didDismissResult(_ sender: Any)
}

@objc(ResultViewController)
class ResultViewController: UIViewController {

    weak var delegate: DismissResultDelegate?
    var scoreRank: Int32 = 0
    var rightAnswers: Int32 = 0
    var wrongAnswers: Int32 = 0
    var totalQuestions: Int32 = 0
    var percentScore: Float = 0
    var timeTakenInSeconds: Int32 = 0

    @IBOutlet private weak var lblScoreMessage: UILabel!
    @IBOutlet private weak var imgViewTopScore: UIImageView?
    @IBOutlet private weak var lblScoreRank: UILabel!
    @IBOutlet private weak var txtName: UITextField!
    @IBOutlet private weak var btnSave: UIButton!
    @IBOutlet private weak var lblRightAnswers: UILabel!
    @IBOutlet private weak var lblWrongAnswers: UILabel!
    @IBOutlet private weak var lblPercentScore: UILabel!
    @IBOutlet private weak var lblTotalQuestions: UILabel!
    @IBOutlet private weak var lblTimeTaken: UILabel!
    @IBOutlet private weak var btnDone: UIButton!
    @IBOutlet private weak var btnDismissKeyboard: UIButton?
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var topScoreHeaderView: UIView!
    @IBOutlet private weak var noTopScoreHeaderView: UIView!

    private let contentContainer = UIView()
    private var contentBaseSize: CGSize = .zero

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kStrResult
        view.backgroundColor = .white

        // Wrap the fixed-size XIB content in a container we can aspect-fit to any
        // screen, so nothing (score message at top, seconds at bottom) is clipped.
        // Use the XIB design size, not the runtime view size (which is full-screen
        // and would leave the content small with white margins).
        contentBaseSize = UIDevice.current.userInterfaceIdiom == .pad
            ? CGSize(width: 768, height: 1024)
            : CGSize(width: 320, height: 568)
        contentContainer.frame = CGRect(origin: .zero, size: contentBaseSize)
        for sub in view.subviews { contentContainer.addSubview(sub) }
        view.addSubview(contentContainer)

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(goHome(_:)))

        // Hide the bare rank number that floated above the congratulations text.
        lblScoreRank.isHidden = true

        // Legacy roundedRect buttons render as plain text on modern iOS — give them
        // a real button appearance at a sensible size.
        styleButton(btnSave)
        styleButton(btnDone)

        lblRightAnswers.text = "\(rightAnswers)"
        lblWrongAnswers.text = "\(wrongAnswers)"
        lblTotalQuestions.text = "\(totalQuestions)"
        lblPercentScore.text = String(format: "%1.2f%%", percentScore * 100)
        lblTimeTaken.text = "\(timeTakenInSeconds) seconds"

        let card = ScoreCard()
        let state = KidsTimeFunAppState.sharedState()
        card.playerName = state.playerName
        card.activity = state.activity
        card.activityType = state.activityType
        card.activityLevel = state.activityLevel
        card.questionsAsked = totalQuestions
        card.questionsAttempted = totalQuestions
        card.rightAnswers = rightAnswers
        card.wrongAnswers = wrongAnswers
        card.percentScore = percentScore
        card.secondsTaken = timeTakenInSeconds
        card.newScoreCard()

        if card.isTopScore {
            headerView.addSubview(topScoreHeaderView)
            lblScoreRank.text = "\(card.scoreRank)"
            txtName.text = state.playerName == kDefaultPlayerName ? "" : state.playerName
            txtName.isEnabled = true
            btnSave.isEnabled = true
        } else {
            headerView.addSubview(noTopScoreHeaderView)
        }
    }

    @IBAction func dismissKeyboard() {
        if let text = txtName.text, !text.isEmpty {
            KidsTimeFunAppState.sharedState().playerName = text
        }
        txtName.resignFirstResponder()
    }

    @IBAction func saveScore() {
        dismissKeyboard()
        let card = ScoreCard()
        let state = KidsTimeFunAppState.sharedState()
        card.playerName = state.playerName
        card.activity = state.activity
        card.activityType = state.activityType
        card.activityLevel = state.activityLevel
        card.questionsAsked = totalQuestions
        card.questionsAttempted = totalQuestions
        card.rightAnswers = rightAnswers
        card.wrongAnswers = wrongAnswers
        card.percentScore = percentScore
        card.secondsTaken = timeTakenInSeconds
        card.newScoreCard()

        if card.isTopScore && !card.writeScoreCard() {
            let alert = UIAlertController(title: "File Alert!", message: "Could not write score to the file. Please contact support.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }

        txtName.isEnabled = false
        btnSave.isEnabled = false
        if let vcs = navigationController?.viewControllers {
            navigationController?.popToViewController(vcs[0], animated: true)
        }
    }

    @IBAction func done() {
        delegate?.didDismissResult(self)
    }

    @objc private func goHome(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    private func styleButton(_ button: UIButton?) {
        guard let button = button else { return }
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1.0)
        button.backgroundColor = tint
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .disabled)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        // Cap the size so the oversized iPad XIB button isn't huge.
        var f = button.frame
        f.size = CGSize(width: min(f.width, 120), height: min(f.height, 48))
        button.frame = f
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard contentBaseSize.width > 0, contentBaseSize.height > 0 else { return }
        let safe = view.bounds.inset(by: view.safeAreaInsets)
        let scale = min(safe.width / contentBaseSize.width, safe.height / contentBaseSize.height)
        contentContainer.transform = .identity
        contentContainer.bounds = CGRect(origin: .zero, size: contentBaseSize)
        contentContainer.transform = CGAffineTransform(scaleX: scale, y: scale)
        contentContainer.center = CGPoint(x: safe.midX, y: safe.midY)
    }
}
