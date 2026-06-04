// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(SetTimeViewController)
class SetTimeViewController: BaseViewController {

    weak var delegate: DismissActivityDelegate?
    private(set) var isRight = false
    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var gradeLevel: Int32 = 0
    var timeOffset: Int32 = 0

    @IBOutlet private weak var clockContainerView: UIView!
    @IBOutlet private weak var rightOrWrong: UIImageView!
    @IBOutlet private weak var rightOrWrong2: UIImageView?
    @IBOutlet private weak var labelQuestion: UILabel!

    private var setClockView: SetClockView!
    private var randomNumber: RandomInteger!
    private var setHours = 0, setMinutes = 0, wrongCounter = 0
    private var recordedAnswer = false // ensure the adaptive engine logs only the first attempt

    override func viewDidLoad() {
        // Grade level sets how fine the target time can be (the hands the child
        // must set): first grade lands on the half hour, third grade on the minute.
        let timeInterval: Int
        switch gradeLevel {
        case kGradeFirst:  timeInterval = 30
        case kGradeSecond: timeInterval = 15
        case kGradeThird:  timeInterval = 5
        default:           timeInterval = 30
        }

        randomNumber = RandomInteger(range: 1, to: 12)
        setHours = randomNumber.randomInteger
        // Adaptive drilling: bias the target minute toward the values this child
        // sets wrong most (random warm-up / variety falls back to a random minute).
        let randomMinute = (randomNumber.nextRandomInteger(inRange: 0, to: 59) / timeInterval) * timeInterval
        setMinutes = AdaptiveDrill.shared.nextTargetMinute(grade: gradeLevel, activity: activity, interval: timeInterval) ?? randomMinute

        let timeStr = String(format: "%d:%02d", setHours, setMinutes)
        labelQuestion.text = "Move the clock hands to \(timeStr)"
        AudioPlayer.getInstance().playAudioFile("move_the_clock_hands_to", withTime: timeStr)

        setClockView = SetClockView(frame: clockContainerView.bounds)
        setClockView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        view.bringSubviewToFront(labelQuestion)
        clockContainerView.addSubview(setClockView)

        super.viewDidLoad()

        // Move VoiceOver focus to the instruction once this activity is on screen.
        if let q = labelQuestion {
            DispatchQueue.main.async { UIAccessibility.post(notification: .screenChanged, argument: q) }
        }
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

        let correct = rightHours && abs(setMinutes - Int(setClockView.minutes)) < 2

        // Log the first attempt for this question's minute bucket so the adaptive
        // engine learns which target times this child struggles to set.
        if !recordedAnswer {
            recordedAnswer = true
            AdaptiveDrill.shared.record(grade: gradeLevel, activity: activity, minute: setMinutes, correct: correct)
        }

        if correct {
            isRight = true
            rightOrWrong2?.image = UIImage(named: "Right"); rightOrWrong.image = UIImage(named: "GoodJob")
            rightOrWrong2?.isHidden = false
            AudioPlayer.getInstance().playCorrectWrong(true)
            ktfAnnounce("Correct!")
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(rightAnswer), userInfo: nil, repeats: false)
        } else {
            isRight = false; wrongCounter += 1
            rightOrWrong2?.image = UIImage(named: "Wrong"); rightOrWrong.image = UIImage(named: "TryAgain")
            AudioPlayer.getInstance().playCorrectWrong(false)
            ktfAnnounce("Not quite, try again.")
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
