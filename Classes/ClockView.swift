import UIKit

class ClockView: UIView {

    var hours: Float = 0
    var minutes: Float = 0
    var seconds: Float = 0
    var PM: Bool = false
    var showSeconds: Bool = false
    var showClockAsAnalog: Bool = true
    var showMinutesOffsetInHoursHand: Bool = false
    var showAMPM: Bool = false
    var showDayNight: Bool = false

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        let x0: CGFloat = 0, y0: CGFloat = 0
        let xl = bounds.size.width
        let yw = bounds.size.height
        let d = min(xl - x0, yw - y0)
        let r = d / 2
        let xc = (x0 + xl) / 2
        let yc = (y0 + yw) / 2
        let x = xc - r
        let y = yc - r

        UIImage(named: "Clock Face")?.draw(in: CGRect(x: x, y: y, width: d, height: d))

        // Hours hand
        let rh = r * 0.40
        let thetaH: CGFloat
        if showMinutesOffsetInHoursHand {
            thetaH = (CGFloat.pi / 2) - (((CGFloat(hours) * 2 * CGFloat.pi) / 12) + ((CGFloat(minutes) / 60) * (0.75 * 2 * CGFloat.pi / 12)))
        } else {
            thetaH = (CGFloat.pi / 2) - ((CGFloat(hours) * 2 * CGFloat.pi) / 12)
        }
        drawHand(context: context, cx: xc, cy: yc, radius: rh, theta: thetaH, width: 3.0, color: UIColor.purple)

        // Minutes hand
        let rm = r * 0.60
        let thetaM = (CGFloat.pi / 2) - ((CGFloat(minutes) * 2 * CGFloat.pi) / 60)
        drawHand(context: context, cx: xc, cy: yc, radius: rm, theta: thetaM, width: 3.0, color: UIColor.purple)

        // Seconds hand (optional)
        if showSeconds {
            let rs = r * 0.64
            let thetaS = (CGFloat.pi / 2) - ((CGFloat(seconds) * 2 * CGFloat.pi) / 60)
            drawHand(context: context, cx: xc, cy: yc, radius: rs, theta: thetaS, width: 1.0, color: UIColor.purple)
        }

        // Center circle
        context.setLineWidth(1.0)
        context.setLineCap(.round)
        context.setAlpha(0.75)
        context.setStrokeColor(UIColor.purple.cgColor)
        context.setFillColor(UIColor.purple.cgColor)
        context.fillEllipse(in: CGRect(x: xc - 4, y: yc - 4, width: 8, height: 8))
        context.setShadow(offset: CGSize(width: 1, height: 1), blur: 1)
        context.strokePath()
    }

    private func drawHand(context: CGContext, cx: CGFloat, cy: CGFloat,
                           radius: CGFloat, theta: CGFloat, width: CGFloat, color: UIColor) {
        let x = radius * cos(theta) + cx
        let y = -radius * sin(theta) + cy
        context.setLineWidth(width)
        context.setLineCap(.round)
        context.setAlpha(0.75)
        context.setStrokeColor(color.cgColor)
        context.setFillColor(color.cgColor)
        context.setShadow(offset: CGSize(width: 1, height: 1), blur: 1)
        context.move(to: CGPoint(x: cx, y: cy))
        context.addLine(to: CGPoint(x: x, y: y))
        context.strokePath()
    }
}
