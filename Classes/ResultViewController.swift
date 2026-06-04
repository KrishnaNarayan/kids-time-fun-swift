// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

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
    /// Belt-engine outcome supplied by ActivityViewController.
    var outcomeMessage: String?
    var awardedBeltImageName: String?
    /// true when the session continues (next or repeated round); false when the
    /// belt was earned/mastered and the only action is to return to the menu.
    var canContinue: Bool = false

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

    override func viewDidLoad() {
        super.viewDidLoad()
        installLegacyScaling()
        title = kStrResult

        let homeBtn = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: self, action: #selector(goHome(_:)))
        homeBtn.accessibilityLabel = "Home"
        navigationItem.leftBarButtonItem = homeBtn

        // Hide the bare rank number that floated above the congratulations text.
        lblScoreRank.isHidden = true

        // Legacy roundedRect buttons render as plain text on modern iOS — give them
        // a real button appearance at a sensible size.
        styleButton(btnSave)
        styleButton(btnDone)
        // The primary button either continues the belt session or finishes it.
        btnDone.setTitle(canContinue ? "Continue" : "Done", for: .normal)
        btnDone.accessibilityLabel = canContinue ? "Continue" : "Done"

        lblRightAnswers.text = "\(rightAnswers)"
        lblWrongAnswers.text = "\(wrongAnswers)"
        lblTotalQuestions.text = "\(totalQuestions)"
        lblPercentScore.text = String(format: "%1.2f%%", percentScore * 100)
        lblTimeTaken.text = "\(timeTakenInSeconds) seconds"

        // The belt-progression engine replaces the old per-run high-score list, so
        // the header now reports the belt outcome (advanced / repeat / earned a
        // belt) instead of asking for a name to save a score.
        let message = outcomeMessage ?? ""
        headerView.addSubview(topScoreHeaderView)
        lblScoreMessage.text = message
        lblScoreMessage.numberOfLines = 0
        lblScoreRank.isHidden = true
        txtName.isHidden = true
        btnSave.isHidden = true

        // Show the earned belt graphic when one was just awarded; otherwise keep
        // the encouraging default art.
        if let beltName = awardedBeltImageName, let belt = UIImage(named: beltName) {
            imgViewTopScore?.image = belt
            imgViewTopScore?.accessibilityLabel = beltName
        }

        if !message.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }

    // The old high-score "save your name" flow was retired when belts replaced
    // Top Scores; the name field and Save button are hidden. These IBActions are
    // kept as no-ops so the ResultView XIB's connections remain valid.
    @IBAction func dismissKeyboard() {}
    @IBAction func saveScore() {}

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
        // Cap the size so the oversized iPad XIB button isn't huge. Shrink toward the
        // button's right edge and vertical center so it stays in its corner and
        // doesn't overlap the name field.
        let newW = min(button.frame.width, 90)
        let newH = min(button.frame.height, 42)
        var f = button.frame
        f.origin.x += f.width - newW
        f.origin.y += (f.height - newH) / 2
        f.size = CGSize(width: newW, height: newH)
        button.frame = f
    }
}
