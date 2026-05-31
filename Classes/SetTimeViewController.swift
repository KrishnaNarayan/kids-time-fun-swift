// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(SetTimeViewController)
class SetTimeViewController: BaseViewController {

    weak var delegate: DismissActivityDelegate?
    private(set) var isRight = false
    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var timeOffset: Int32 = 0

    @IBOutlet private weak var clockContainerView: UIView!
    @IBOutlet private weak var rightOrWrong: UIImageView!
    @IBOutlet private weak var rightOrWrong2: UIImageView?
    @IBOutlet private weak var labelQuestion: UILabel!

    private var setClockView: SetClockView!
    private var randomNumber: RandomInteger!
    private var setHours = 0, setMinutes = 0, wrongCounter = 0

    override func viewDidLoad() {
        let timeInterval: Int
        switch activityLevel {
        case kActLevelYellowBelt: timeInterval = 30
        case kActLevelGreenBelt:  timeInterval = 15
        case kActLevelRedBelt:    timeInterval = 5
        case kActLevelBlackBelt:  timeInterval = 1
        default:                  timeInterval = 30
        }

        randomNumber = RandomInteger(range: 1, to: 12)
        setHours = randomNumber.randomInteger
        setMinutes = (randomNumber.nextRandomInteger(inRange: 0, to: 59) / timeInterval) * timeInterval

        let timeStr = String(format: "%d:%02d", setHours, setMinutes)
        labelQuestion.text = "Move the clock hands to \(timeStr)"
        AudioPlayer.getInstance().playAudioFile("move_the_clock_hands_to", withTime: timeStr)

        setClockView = SetClockView(frame: clockContainerView.bounds)
        setClockView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.bringSubviewToFront(labelQuestion)
        clockContainerView.addSubview(setClockView)

        super.viewDidLoad()
    }

    @IBAction func setTimeButtonPushed() {
        var rightHours = false
        var hrs = Int(round(Double(setClockView.hours)))
        if hrs == 12 { hrs = 0 }
        var tempHrs = setHours
        if tempHrs == 12 { tempHrs = 0 }

        let upperBound = min(hrs + 1, Int((Double(hrs) + Double(setClockView.minutes) / 60.0) * 1.1))
        if Int(setClockView.hours) >= tempHrs && Int(setClockView.hours) <= upperBound {
            rightHours = true
        }

        if rightHours && abs(setMinutes - Int(setClockView.minutes)) < 2 {
            isRight = true
            rightOrWrong2?.image = UIImage(named: "Right"); rightOrWrong.image = UIImage(named: "GoodJob")
            rightOrWrong2?.isHidden = false
            AudioPlayer.getInstance().playCorrectWrong(true)
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(rightAnswer), userInfo: nil, repeats: false)
        } else {
            isRight = false; wrongCounter += 1
            rightOrWrong2?.image = UIImage(named: "Wrong"); rightOrWrong.image = UIImage(named: "TryAgain")
            AudioPlayer.getInstance().playCorrectWrong(false)
            rightOrWrong2?.isHidden = true; rightOrWrong.isHidden = false
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(wrongAnswer), userInfo: nil, repeats: false)
        }
    }

    @objc func rightAnswer() {
        if wrongCounter > 0 { isRight = false; wrongCounter = 0 }
        delegate?.didDismissActivity(self)
    }

    @objc func wrongAnswer() {
        if activityType != kActTypeTimed {
            rightOrWrong.image = nil; rightOrWrong2?.image = nil
            rightOrWrong2?.isHidden = true
            view.setNeedsDisplay()
        } else {
            delegate?.didDismissActivity(self)
        }
    }
}
