// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(ActivityHeaderView)
class ActivityHeaderView: UIView {

    var activityLevel: Int32 = 0
    var right: Int32 = 0
    var wrong: Int32 = 0
    var current: Int32 = 0
    var total: Int32 = 0
    var showTotal: Bool = false
    var showTimer: Bool = false
    var countdownTimer: Int32 = 0

    @IBOutlet private weak var rightLabel: UILabel!
    @IBOutlet private weak var wrongLabel: UILabel!
    @IBOutlet private weak var countdownLabel: UILabel!
    @IBOutlet private weak var pageLabel: UILabel!
    @IBOutlet private weak var timerImg: UIImageView!
    @IBOutlet private weak var activityLevelImg: UIImageView!

    // VoiceOver: read the whole header as a single progress/score summary
    // instead of the individual bare numbers.
    override var isAccessibilityElement: Bool {
        get { true }
        set { }
    }
    override var accessibilityLabel: String? {
        get {
            var parts = ["\(right) correct", "\(wrong) wrong"]
            if showTotal {
                parts.append("question \(current) of \(total)")
            } else {
                parts.append("question \(current)")
            }
            if showTimer {
                parts.append("\(countdownTimer) seconds left")
            }
            return parts.joined(separator: ", ")
        }
        set { }
    }

    override func draw(_ rect: CGRect) {
        switch activityLevel {
        case kActLevelYellowBelt: activityLevelImg.image = UIImage(named: "Yellow Belt")
        case kActLevelGreenBelt:  activityLevelImg.image = UIImage(named: "Green Belt")
        case kActLevelRedBelt:    activityLevelImg.image = UIImage(named: "Red Belt")
        case kActLevelBlackBelt:  activityLevelImg.image = UIImage(named: "Black Belt")
        default: activityLevelImg.image = nil   // no belt earned yet for this activity/grade
        }

        // The timer box (left) and the question counter (right) occupy different
        // spots in the header, so a timed round shows BOTH: the countdown plus the
        // "x / total" progress toward the round's fixed question count.
        if showTimer {
            timerImg.isHidden = false
            countdownLabel.isHidden = false
        } else {
            timerImg.isHidden = true
            countdownLabel.isHidden = true
        }

        rightLabel.text = "\(right)"
        wrongLabel.text = "\(wrong)"
        pageLabel.text = showTotal ? "\(current)/\(total)" : "\(current)"
        countdownLabel.text = "\(countdownTimer)"

        if countdownTimer < 10 {
            countdownLabel.textColor = UIColor(red: 0.5, green: 0, blue: 0, alpha: 1)
        }
    }
}
