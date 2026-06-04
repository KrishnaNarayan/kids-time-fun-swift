// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(TellTimeViewController)
class TellTimeViewController: BaseViewController {

    weak var delegate: DismissActivityDelegate?
    private(set) var isRight = false
    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var gradeLevel: Int32 = 0
    var timeOffset: Int32 = 0
    var answerIndex: Int = 0

    @IBOutlet private weak var clockContainerView: UIView!
    @IBOutlet private weak var choices2: UISegmentedControl!
    @IBOutlet private weak var choices3: UISegmentedControl!
    @IBOutlet private weak var choices4: UISegmentedControl!
    @IBOutlet private weak var rightOrWrong: UIImageView!
    @IBOutlet private weak var rightOrWrong2: UIImageView?
    @IBOutlet private weak var labelQuestion: UILabel!

    private var clockView: ClockView!
    private var randomNumber: RandomInteger!
    private var choices: UISegmentedControl!
    private var wrongCounter = 0
    private var drilledMinute = 0      // minute bucket this question targets (for adaptive recording)
    private var recordedAnswer = false // ensure we log only the first attempt

    override func viewDidLoad() {
        clockView = ClockView(frame: clockContainerView.bounds)
        clockView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        // Difficulty is now driven by the child's grade level (the single setting),
        // not by an earned belt. Grade sets the clock-time increment, the answer-
        // offset range, and how many answer choices to show.
        let timeInterval: Int, timeRangeLow: Int, timeRangeHigh: Int, numberOfChoices: Int
        switch gradeLevel {
        case kGradeFirst:  (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (30, 30, 120, 2)
        case kGradeSecond: (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (15, 15, 240, 3)
        case kGradeThird:  (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (5, 5, 360, 4)
        default:           (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (30, 30, 120, 2)
        }

        switch numberOfChoices {
        case 2: choices4.isHidden = true;  choices3.isHidden = true;  choices2.isHidden = false; choices = choices2
        case 3: choices4.isHidden = true;  choices3.isHidden = false; choices2.isHidden = true;  choices = choices3
        default:choices4.isHidden = false; choices3.isHidden = true;  choices2.isHidden = true;  choices = choices4
        }
        styleChoices(choices)

        randomNumber = RandomInteger(range: 1, to: 12)
        clockView.hours = Float(randomNumber.randomInteger)
        clockView.PM = randomNumber.nextRandomInteger(inRange: 0, to: 1) != 0
        // Adaptive drilling: after a random warm-up the engine biases the displayed
        // minute toward the values this child reads wrong most; until then (or for
        // variety) it falls back to a random minute at the grade's increment.
        let randomMinute = (randomNumber.nextRandomInteger(inRange: 0, to: 59) / timeInterval) * timeInterval
        drilledMinute = AdaptiveDrill.shared.nextTargetMinute(grade: gradeLevel, activity: activity, interval: timeInterval) ?? randomMinute
        clockView.minutes = Float(drilledMinute)
        clockView.seconds = 0; clockView.showSeconds = false
        clockView.showClockAsAnalog = true; clockView.showMinutesOffsetInHoursHand = true
        clockView.showAMPM = false; clockView.showDayNight = false
        clockContainerView.addSubview(clockView)

        var randomTimeOffset = 0, randomHoursOffset = 0, randomMinutesOffset = 0
        var questionText = ""
        let audio = AudioPlayer.getInstance()
        switch timeOffset {
        case 0:
            questionText = "What time is it?"
            audio.playAudioFile("what_time_is_it")
        case -1:
            randomTimeOffset = (randomNumber.nextRandomInteger(inRange: timeRangeLow, to: timeRangeHigh) / timeInterval) * timeInterval
            randomHoursOffset = randomTimeOffset / 60; randomMinutesOffset = randomTimeOffset - randomHoursOffset * 60
            let (q, hrStr, mnStr) = buildOffsetQuestion(hrs: randomHoursOffset, mins: randomMinutesOffset)
            questionText = "What was the time \(q) ago?"
            audio.playTellTime("what_was_the_time", playHours: randomHoursOffset > 0, hours: hrStr,
                               playMinutes: randomMinutesOffset > 0, minutes: mnStr,
                               playAnd: randomHoursOffset > 0 && randomMinutesOffset > 0, playAgo: true)
        case 1:
            randomTimeOffset = (randomNumber.nextRandomInteger(inRange: timeRangeLow, to: timeRangeHigh) / timeInterval) * timeInterval
            randomHoursOffset = randomTimeOffset / 60; randomMinutesOffset = randomTimeOffset - randomHoursOffset * 60
            let (q, hrStr, mnStr) = buildOffsetQuestion(hrs: randomHoursOffset, mins: randomMinutesOffset)
            questionText = "What will the time be in \(q)?"
            audio.playTellTime("what_will_the_time_be_in", playHours: randomHoursOffset > 0, hours: hrStr,
                               playMinutes: randomMinutesOffset > 0, minutes: mnStr,
                               playAnd: randomHoursOffset > 0 && randomMinutesOffset > 0, playAgo: false)
        default: break
        }
        labelQuestion.text = questionText
        view.bringSubviewToFront(labelQuestion)

        let answerHours: Int, answerMinutes: Int
        if timeOffset == 0 {
            answerHours = Int(clockView.hours); answerMinutes = Int(clockView.minutes)
        } else {
            var total = Int(clockView.hours) * 60 + Int(clockView.minutes) + Int(timeOffset) * randomTimeOffset
            if total < 0 { total += 720 }; if total > 720 { total -= 720 }
            var ah = total / 60; let am = total - ah * 60
            if ah == 0 { ah = 12 }
            answerHours = ah; answerMinutes = am
        }

        var prevH = 0, prevM = 0
        for i in 0..<choices.numberOfSegments {
            var h = 0, m = 0
            repeat {
                h = randomNumber.nextRandomInteger(inRange: 1, to: 12)
                m = (randomNumber.nextRandomInteger(inRange: 0, to: 59) / timeInterval) * timeInterval
            } while (h * 60 + m == prevH * 60 + prevM || h * 60 + m == answerHours * 60 + answerMinutes)
            prevH = h; prevM = m
            choices.setTitle(choiceLabel(h: h, m: m, grade: Int(gradeLevel)), forSegmentAt: i)
        }

        randomNumber.rangeLow = 0; randomNumber.rangeHigh = choices.numberOfSegments - 1
        answerIndex = randomNumber.randomInteger
        choices.setTitle(choiceLabel(h: answerHours, m: answerMinutes, grade: Int(gradeLevel)), forSegmentAt: answerIndex)

        super.viewDidLoad()

        // Move VoiceOver focus to the question once this activity is on screen.
        if let q = labelQuestion {
            DispatchQueue.main.async { UIAccessibility.post(notification: .screenChanged, argument: q) }
        }
    }

    @IBAction func choicesValueChanged() {
        // Log the first attempt for this question's minute bucket so the adaptive
        // engine learns which times this child struggles with.
        if !recordedAnswer {
            recordedAnswer = true
            AdaptiveDrill.shared.record(grade: gradeLevel, activity: activity,
                                        minute: drilledMinute,
                                        correct: choices.selectedSegmentIndex == answerIndex)
        }
        choices.isEnabled = false; choices.isHidden = true
        if choices.selectedSegmentIndex == answerIndex {
            isRight = true
            rightOrWrong.image = UIImage(named: "GoodJob")
            rightOrWrong2?.image = UIImage(named: "Right"); rightOrWrong2?.isHidden = false
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

    @objc private func rightAnswer() {
        if wrongCounter > 0 { isRight = false; wrongCounter = 0 }
        delegate?.didDismissActivity(self)
    }

    @objc private func wrongAnswer() {
        if activityType != kActTypeTimed {
            rightOrWrong.image = nil; rightOrWrong2?.image = nil
            rightOrWrong2?.isHidden = true; choices.isEnabled = true; choices.isHidden = false
            view.setNeedsDisplay()
        } else {
            delegate?.didDismissActivity(self)
        }
    }

    private func choiceLabel(h: Int, m: Int, grade: Int) -> String {
        // Younger grades read whole hours as "o'clock"; third grade uses digital time.
        if (grade == kGradeFirst || grade == kGradeSecond) && m == 0 {
            return "\(h) o'clock"
        }
        return String(format: "%i:%02i", h, m)
    }

    private func buildOffsetQuestion(hrs: Int, mins: Int) -> (String, String, String) {
        let hrStr = hrs > 0 ? "\(hrs) \(hrs == 1 ? "hour" : "hours")" : ""
        let mnStr = mins > 0 ? "\(mins) \(mins == 1 ? "minute" : "minutes")" : ""
        if hrs == 0 { return (mnStr, hrStr, mnStr) }
        if mins == 0 { return (hrStr, hrStr, mnStr) }
        return ("\(hrStr) and \(mnStr)", hrStr, mnStr)
    }
}
