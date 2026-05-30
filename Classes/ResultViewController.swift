import UIKit

@objc protocol DismissResultDelegate: AnyObject {
    func didDismissResult(_ sender: Any)
}

class ResultViewController: UIViewController {

    weak var delegate: DismissResultDelegate?
    var scoreRank: Int32 = 0
    var rightAnswers: Int32 = 0
    var wrongAnswers: Int32 = 0
    var totalQuestions: Int32 = 0
    var percentScore: Float = 0
    var timeTakenInSeconds: Int32 = 0

    @IBOutlet private weak var lblScoreMessage: UILabel!
    @IBOutlet private weak var imgViewTopScore: UIImageView!
    @IBOutlet private weak var lblScoreRank: UILabel!
    @IBOutlet private weak var txtName: UITextField!
    @IBOutlet private weak var btnSave: UIButton!
    @IBOutlet private weak var lblRightAnswers: UILabel!
    @IBOutlet private weak var lblWrongAnswers: UILabel!
    @IBOutlet private weak var lblPercentScore: UILabel!
    @IBOutlet private weak var lblTotalQuestions: UILabel!
    @IBOutlet private weak var lblTimeTaken: UILabel!
    @IBOutlet private weak var btnDone: UIButton!
    @IBOutlet private weak var btnDismissKeyboard: UIButton!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var topScoreHeaderView: UIView!
    @IBOutlet private weak var noTopScoreHeaderView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kStrResult

        let homeBtn = UIBarButtonItem(image: UIImage(named: "Home.png"), style: .bordered, target: self, action: #selector(goHome(_:)))
        navigationItem.leftBarButtonItem = homeBtn

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
            let alert = UIAlertView(title: "File Alert!", message: "Could not write score to the file. Please contact support.", delegate: nil, cancelButtonTitle: "Okay")
            alert.show()
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
}
