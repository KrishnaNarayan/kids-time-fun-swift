// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc protocol DismissActivityDelegate: AnyObject {
    func didDismissActivity(_ sender: Any)
}

/// Container that aspect-fits its `content` (a fixed-size legacy layout) into its
/// own safe area. Used to make 320x568 / 768x1024 XIB screens fill modern devices.
final class LegacyScalingView: UIView {
    let content = UIView()
    var baseSize: CGSize = .zero

    override func layoutSubviews() {
        super.layoutSubviews()
        guard baseSize.width > 0, baseSize.height > 0 else { return }
        let safe = bounds.inset(by: safeAreaInsets)
        guard safe.width > 0, safe.height > 0 else { return }
        let scale = min(safe.width / baseSize.width, safe.height / baseSize.height)
        content.transform = .identity
        content.bounds = CGRect(origin: .zero, size: baseSize)
        content.transform = CGAffineTransform(scaleX: scale, y: scale)
        content.center = CGPoint(x: safe.midX, y: safe.midY)
    }
}

extension UIViewController {
    /// On iPad, enlarge a segmented control's text and height so it isn't thin and
    /// out of proportion with the large buttons.
    func enlargeSegmentedControlForIPad(_ control: UISegmentedControl?) {
        guard UIDevice.current.userInterfaceIdiom == .pad, let control = control else { return }
        let font = UIFont.boldSystemFont(ofSize: 24)
        for state: UIControl.State in [.normal, .selected] {
            var attrs = control.titleTextAttributes(for: state) ?? [:]
            attrs[.font] = font
            control.setTitleTextAttributes(attrs, for: state)
        }
        var f = control.frame
        f.size.height = max(f.size.height, 54)
        control.frame = f
    }

    /// The design size of the legacy XIBs for the current device family.
    var legacyBaseSize: CGSize {
        UIDevice.current.userInterfaceIdiom == .pad
            ? CGSize(width: 768, height: 1024)
            : CGSize(width: 320, height: 568)
    }

    /// Reparent all of the controller's current subviews into an aspect-fitting
    /// container so the fixed-size XIB layout fills modern screens. Call at the
    /// start of viewDidLoad (outlets remain valid — they're just references).
    func installLegacyScaling() {
        // Aspect-fit the fixed-size XIB content (design size) into the safe area.
        // Using the design size keeps every screen filling the width consistently
        // and centered; content is laid out for this size.
        let base = legacyBaseSize
        let container = LegacyScalingView(frame: view.bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.baseSize = base
        container.content.frame = CGRect(origin: .zero, size: base)
        for sub in view.subviews { container.content.addSubview(sub) }
        container.addSubview(container.content)
        view.addSubview(container)
        view.backgroundColor = .white
    }
}

@objc(BaseViewController)
class BaseViewController: UIViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// Give an answer segmented control an opaque, high-contrast appearance with
    /// clear segment boundaries so it's obvious where to tap each answer.
    func styleChoices(_ control: UISegmentedControl?) {
        guard let control = control else { return }
        let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1.0)
        control.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        control.selectedSegmentTintColor = tint
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        // Visible outer border + dividers between segments
        control.layer.cornerRadius = 10
        control.layer.borderWidth = 2
        control.layer.borderColor = tint.cgColor
        control.layer.masksToBounds = true
        let divider = BaseViewController.solidImage(color: tint, size: CGSize(width: 2, height: 1))
        control.setDividerImage(divider, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        enlargeSegmentedControlForIPad(control)
    }

    private static func solidImage(color: UIColor, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
