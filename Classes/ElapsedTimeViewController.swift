import UIKit

@objc(ElapsedTimeViewController)
class ElapsedTimeViewController: BaseViewController {

    weak var delegate: DismissActivityDelegate?
    private(set) var isRight = false
    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var timeOffset: Int32 = 0
    var answerIndex: Int = 0

    @IBOutlet private weak var clockContainerView: UIView!
    @IBOutlet private weak var clockContainerView2: UIView!
    @IBOutlet private weak var choices2: UISegmentedControl!
    @IBOutlet private weak var choices3: UISegmentedControl!
    @IBOutlet private weak var choices4: UISegmentedControl!
    @IBOutlet private weak var rightOrWrong: UIImageView!
    @IBOutlet private weak var rightOrWrong2: UIImageView?
    @IBOutlet private weak var labelQuestion: UILabel!

    private var clockView: ClockView!
    private var clockView2: ClockView!
    private var randomNumber: RandomInteger!
    private var choices: UISegmentedControl!
    private var wrongCounter = 0

    override func viewDidLoad() {
        clockView = ClockView(frame: clockContainerView.bounds)
        clockView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)

        if activity == kActElapsedTime {
            clockView2 = ClockView(frame: clockContainerView.bounds)
            clockView2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        }

        let timeInterval: Int, timeRangeLow: Int, timeRangeHigh: Int, numberOfChoices: Int
        switch activityLevel {
        case kActLevelYellowBelt: (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (30, 30, 120, 2)
        case kActLevelGreenBelt:  (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (15, 15, 240, 3)
        case kActLevelRedBelt:    (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (5, 5, 360, 4)
        case kActLevelBlackBelt:  (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (1, 5, 719, 4)
        default:                  (timeInterval, timeRangeLow, timeRangeHigh, numberOfChoices) = (30, 30, 120, 2)
        }

        switch numberOfChoices {
        case 2: choices4.isHidden = true;  choices3.isHidden = true;  choices2.isHidden = false; choices = choices2
        case 3: choices4.isHidden = true;  choices3.isHidden = false; choices2.isHidden = true;  choices = choices3
        default:choices4.isHidden = false; choices3.isHidden = true;  choices2.isHidden = true;  choices = choices4
        }

        randomNumber = RandomInteger(range: 1, to: 12)
        clockView.hours = Float(randomNumber.randomInteger)
        clockView.PM = randomNumber.nextRandomInteger(inRange: 0, to: 1) != 0
        clockView.minutes = Float((randomNumber.nextRandomInteger(inRange: 0, to: 59) / timeInterval) * timeInterval)
        clockView.seconds = 0; clockView.showSeconds = false
        clockView.showClockAsAnalog = true; clockView.showMinutesOffsetInHoursHand = true
        clockView.showAMPM = false; clockView.showDayNight = false
        clockContainerView.addSubview(clockView)

        labelQuestion.text = "How much time has passed?"
        AudioPlayer.getInstance().playAudioFile("how_much_time_has_past")

        let randomOffset = (randomNumber.nextRandomInteger(inRange: timeRangeLow, to: timeRangeHigh) / timeInterval) * timeInterval
        let answerHours = randomOffset / 60
        let answerMinutes = randomOffset - answerHours * 60

        var c2m = Int(clockView.hours) * 60 + Int(clockView.minutes) + randomOffset
        if c2m < 0 { c2m += 720 }; if c2m > 720 { c2m -= 720 }
        var c2h = c2m / 60; let c2mins = c2m - c2h * 60
        if c2h == 0 { c2h = 12 }
        clockView2.hours = Float(c2h); clockView2.PM = clockView.PM
        clockView2.minutes = Float(c2mins); clockView2.seconds = 0; clockView2.showSeconds = false
        clockView2.showClockAsAnalog = true; clockView2.showMinutesOffsetInHoursHand = true
        clockView2.showAMPM = false; clockView2.showDayNight = false
        clockContainerView2.addSubview(clockView2)

        let answerTitle = answerHours == 0 ? String(format: "%02i min", answerMinutes) : "\(answerHours):\(String(format: "%02i", answerMinutes))"
        var prevH = 0, prevM = 0
        for i in 0..<choices.numberOfSegments {
            var h = 0, m = 0
            repeat {
                h = randomNumber.nextRandomInteger(inRange: max(timeRangeLow / 60, 1), to: timeRangeHigh / 60)
                m = (randomNumber.nextRandomInteger(inRange: 0, to: 59) / timeInterval) * timeInterval
            } while (h * 60 + m == prevH * 60 + prevM || h * 60 + m == answerHours * 60 + answerMinutes)
            prevH = h; prevM = m
            let t = h == 0 ? String(format: "%02i min", m) : "\(h):\(String(format: "%02i", m))"
            choices.setTitle(t, forSegmentAt: i)
        }

        randomNumber.rangeLow = 0; randomNumber.rangeHigh = choices.numberOfSegments - 1
        answerIndex = randomNumber.randomInteger
        choices.setTitle(answerTitle, forSegmentAt: answerIndex)

        super.viewDidLoad()
        edgesForExtendedLayout = []
    }

    @IBAction func choicesValueChanged() {
        choices.isEnabled = false; choices.isHidden = true
        if choices.selectedSegmentIndex == answerIndex {
            isRight = true
            rightOrWrong.image = UIImage(named: "GoodJob")
            rightOrWrong2?.image = UIImage(named: "Right"); rightOrWrong2?.isHidden = false
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
}
