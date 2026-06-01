// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
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
            if showTimer {
                parts.append("\(countdownTimer) seconds left")
            } else if showTotal {
                parts.append("question \(current) of \(total)")
            } else {
                parts.append("question \(current)")
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
        default: break
        }

        if showTimer {
            timerImg.isHidden = false
            countdownLabel.isHidden = false
            showTotal = false
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
