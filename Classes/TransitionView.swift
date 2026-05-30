import UIKit
import QuartzCore

@objc protocol TransitionViewDelegate: AnyObject {
    @objc optional func transitionViewDidStart(_ view: TransitionView)
    @objc optional func transitionViewDidFinish(_ view: TransitionView)
    @objc optional func transitionViewDidCancel(_ view: TransitionView)
}

class TransitionView: UIView {

    weak var delegate: TransitionViewDelegate?
    private(set) var isTransitioning = false
    private var wasEnabled = false

    private static let animationKey = "transitionViewAnimation"

    func replaceSubview(_ oldView: UIView, withSubview newView: UIView,
                        transition: String, direction: String, duration: TimeInterval) {
        guard !isTransitioning else { return }

        var index: Int = 0
        if oldView.superview == self {
            index = subviews.firstIndex(of: oldView) ?? 0
            oldView.removeFromSuperview()
        }

        if newView.superview == nil {
            insertSubview(newView, at: index)
        }

        let animation = CATransition()
        animation.delegate = self

        if transition == kCATransitionFade {
            animation.type = CATransitionType.fade
        } else {
            animation.type = CATransitionType(rawValue: transition)
            animation.subtype = CATransitionSubtype(rawValue: direction)
        }

        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: TransitionView.animationKey)
    }

    func cancelTransition() {
        layer.removeAnimation(forKey: TransitionView.animationKey)
    }
}

extension TransitionView: CAAnimationDelegate {

    func animationDidStart(_ anim: CAAnimation) {
        isTransitioning = true
        wasEnabled = isUserInteractionEnabled
        if wasEnabled { isUserInteractionEnabled = false }
        delegate?.transitionViewDidStart?(self)
    }

    func animationDidStop(_ anim: CAAnimation, finished: Bool) {
        isTransitioning = false
        if wasEnabled { isUserInteractionEnabled = true }
        if finished {
            delegate?.transitionViewDidFinish?(self)
        } else {
            delegate?.transitionViewDidCancel?(self)
        }
    }
}
