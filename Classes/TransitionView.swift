// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit
import QuartzCore

@objc protocol TransitionViewDelegate: AnyObject {
    @objc optional func transitionViewDidStart(_ view: TransitionView)
    @objc optional func transitionViewDidFinish(_ view: TransitionView)
    @objc optional func transitionViewDidCancel(_ view: TransitionView)
}

@objc(TransitionView)
class TransitionView: UIView {

    @objc weak var delegate: TransitionViewDelegate?
    private(set) var isTransitioning = false
    private var wasEnabled = false

    private static let animationKey = "transitionViewAnimation"

    func replaceSubview(_ oldView: UIView, withSubview newView: UIView,
                        transition: CATransitionType, direction: CATransitionSubtype, duration: TimeInterval) {
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

        if transition == .fade {
            animation.type = .fade
        } else {
            animation.type = transition
            animation.subtype = direction
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
