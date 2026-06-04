// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(SetClockView)
class SetClockView: UIView {

    var hours: Float = 12
    var minutes: Float = 30
    var showMinutesOffsetInHoursHand: Bool = false

    private var r: CGFloat = 0, xc: CGFloat = 0, yc: CGFloat = 0
    private var rh: CGFloat = 0, rm: CGFloat = 0
    private var thetaH: CGFloat = 0, thetaM: CGFloat = 0
    private var xHourHand: CGFloat = 0, yHourHand: CGFloat = 0
    private var xMinuteHand: CGFloat = 0, yMinuteHand: CGFloat = 0
    private var touchX: CGFloat = 0, touchY: CGFloat = 0
    private var hourHandFlag = false, minuteHandFlag = false, firstPass = true

    // VoiceOver: describe the clock and let the user drag the hands directly
    // (allowsDirectInteraction passes touches straight through to this view).
    override var isAccessibilityElement: Bool {
        get { true }
        set { }
    }
    override var accessibilityLabel: String? {
        get {
            let now = ktfSpokenTime(hours: Int(hours.rounded()), minutes: Int(minutes.rounded()))
            return "Adjustable clock, currently set to \(now). Touch and drag the hour and minute hands to set the time."
        }
        set { }
    }
    override var accessibilityTraits: UIAccessibilityTraits {
        get { [.allowsDirectInteraction] }
        set { }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let x0: CGFloat = 0, y0: CGFloat = 0
        let xl = bounds.size.width
        let yw = bounds.size.height
        let d = min(xl - x0, yw - y0)
        r = d / 2
        xc = (x0 + xl) / 2
        yc = (y0 + yw) / 2

        UIImage(named: "Clock Face")?.draw(in: CGRect(x: xc - r, y: yc - r, width: d, height: d))

        showMinutesOffsetInHoursHand = false

        // Hours hand
        rh = r * 0.65
        if showMinutesOffsetInHoursHand {
            thetaH = (CGFloat.pi / 2) - (((CGFloat(hours) * 2 * CGFloat.pi) / 12) + ((CGFloat(minutes) / 60) * (0.75 * 2 * CGFloat.pi / 12)))
        } else {
            thetaH = (CGFloat.pi / 2) - ((CGFloat(hours) * 2 * CGFloat.pi) / 12)
        }

        var hx = rh * cos(thetaH) + xc
        var hy = -rh * sin(thetaH) + yc

        if hourHandFlag && !firstPass {
            let theta = atan2(xc - touchX, touchY - yc) + CGFloat.pi / 2
            hx = r * 0.65 * cos(theta) + xc
            hy = r * 0.65 * sin(theta) + yc
            hours = Float((theta + CGFloat.pi / 2) * 6 / CGFloat.pi)
        }

        context.setLineWidth(7.0)
        context.setLineCap(.round)
        context.setAlpha(1.0)
        context.setStrokeColor(UIColor.blue.cgColor)
        context.setShadow(offset: CGSize(width: 1, height: 1), blur: 1)
        context.move(to: CGPoint(x: xc, y: yc))
        context.addLine(to: CGPoint(x: hx, y: hy))
        context.strokePath()
        xHourHand = hx
        yHourHand = hy

        // Minutes hand
        rm = r * 0.80
        thetaM = (CGFloat.pi / 2) - ((CGFloat(minutes) * 2 * CGFloat.pi) / 60)
        var mx = rm * cos(thetaM) + xc
        var my = -rm * sin(thetaM) + yc

        if minuteHandFlag && !firstPass {
            let theta = atan2(xc - touchX, touchY - yc) + CGFloat.pi / 2
            mx = r * 0.85 * cos(theta) + xc
            my = r * 0.85 * sin(theta) + yc
            var mins = Float((theta + CGFloat.pi / 2) * 30 / CGFloat.pi)
            if mins == 60 { mins = 59.99 }
            minutes = mins
        }

        minutes = Float(round(Double(minutes)) == 60 ? 0 : round(Double(minutes)))

        context.setLineWidth(5.0)
        context.setLineCap(.round)
        context.setAlpha(1.0)
        context.setStrokeColor(UIColor.green.cgColor)
        context.setShadow(offset: CGSize(width: 1, height: 1), blur: 1)
        context.move(to: CGPoint(x: xc, y: yc))
        context.addLine(to: CGPoint(x: mx, y: my))
        context.strokePath()
        xMinuteHand = mx
        yMinuteHand = my

        // Center circle
        context.setLineWidth(2.0)
        context.setAlpha(1.0)
        context.setStrokeColor(UIColor.black.cgColor)
        context.setFillColor(UIColor.black.cgColor)
        context.fillEllipse(in: CGRect(x: xc - 4, y: yc - 4, width: 8, height: 8))
        context.setShadow(offset: CGSize(width: 1, height: 1), blur: 1)
        context.strokePath()

        firstPass = false

        if hours == 12.0 { hours = 0 }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchX = touch.location(in: self).x
        touchY = touch.location(in: self).y
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        hourHandFlag = false
        minuteHandFlag = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        touchX = touch.location(in: self).x
        touchY = touch.location(in: self).y

        let thetaTouch = atan2(touchY - yc, touchX - xc)
        let thetaHoursHand = atan2(yHourHand - yc, xHourHand - xc)
        let thetaMinutesHand = atan2(yMinuteHand - yc, xMinuteHand - xc)

        if abs(thetaTouch - thetaHoursHand) < abs(thetaTouch - thetaMinutesHand) {
            hourHandFlag = true
            minuteHandFlag = false
        } else {
            hourHandFlag = false
            minuteHandFlag = true
        }
    }
}
