// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc protocol DismissActivityDelegate: AnyObject {
    func didDismissActivity(_ sender: Any)
}

/// A clock time spoken the way VoiceOver should read it (e.g. "3 o'clock",
/// "3 oh 5", "3 15"). Avoids the literal "three colon one five" that a raw
/// "3:15" string would produce.
func ktfSpokenTime(hours: Int, minutes: Int) -> String {
    var h = hours % 12
    if h == 0 { h = 12 }
    let m = ((minutes % 60) + 60) % 60
    if m == 0 { return "\(h) o'clock" }
    if m < 10 { return "\(h) oh \(m)" }
    return "\(h) \(m)"
}

extension UIImage {
    /// The average color of the image's bottom row of pixels — used to extend a
    /// scaled-down legacy background seamlessly into the gap beneath it.
    func bottomEdgeColor() -> UIColor? {
        guard let cg = cgImage else { return nil }
        let h = cg.height
        let strip = CGRect(x: 0, y: max(0, h - 2), width: cg.width, height: min(2, h))
        guard let crop = cg.cropping(to: strip) else { return nil }
        var pixel: [UInt8] = [0, 0, 0, 0]
        let space = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8,
                                  bytesPerRow: 4, space: space,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.interpolationQuality = .medium
        ctx.draw(crop, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        let a = CGFloat(pixel[3]) / 255
        guard a > 0 else { return nil }
        return UIColor(red: CGFloat(pixel[0]) / 255, green: CGFloat(pixel[1]) / 255,
                       blue: CGFloat(pixel[2]) / 255, alpha: a)
    }
}

extension UIViewController {
    /// Speak a message via VoiceOver (no-op when VoiceOver is off).
    func ktfAnnounce(_ message: String) {
        guard UIAccessibility.isVoiceOverRunning else { return }
        UIAccessibility.post(notification: .announcement, argument: message)
    }
}

/// Container that aspect-fits its `content` (a fixed-size legacy layout) into its
/// own safe area. Used to make 320x568 / 768x1024 XIB screens fill modern devices.
final class LegacyScalingView: UIView {
    let content = UIView()
    var baseSize: CGSize = .zero
    var topAligned = false

    override func layoutSubviews() {
        super.layoutSubviews()
        guard baseSize.width > 0, baseSize.height > 0 else { return }
        let safe = bounds.inset(by: safeAreaInsets)
        guard bounds.width > 0, bounds.height > 0 else { return }

        // Always center on (and scale to) the FULL width. Some simulators/devices
        // report a spurious horizontal safe-area inset in portrait, which used to
        // shift the canvas left and shrink it, leaving a white strip down one edge.
        let scale: CGFloat
        let centerY: CGFloat
        if topAligned {
            // Menu: fill the full width and pin to the top of the safe area. On tall
            // phones the canvas overflows the bottom (only decorative background is
            // clipped); on wider tablets a bottom gap remains and is filled by the
            // container's background color.
            scale = bounds.width / baseSize.width
            centerY = safe.minY + (baseSize.height * scale) / 2
        } else {
            // Other screens: aspect-fit within the safe height, vertically centered.
            scale = min(bounds.width / baseSize.width, safe.height / baseSize.height)
            centerY = safe.midY
        }
        content.transform = .identity
        content.bounds = CGRect(origin: .zero, size: baseSize)
        content.transform = CGAffineTransform(scaleX: scale, y: scale)
        content.center = CGPoint(x: bounds.midX, y: centerY)
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

    /// For table-based legacy screens: make the background image (aspect-fill) and
    /// the table fill the whole view. Call from viewDidLayoutSubviews.
    func layoutLegacyTableAndBackground() {
        for sub in view.subviews {
            if let img = sub as? UIImageView {
                img.contentMode = .scaleAspectFill
                img.clipsToBounds = true
                img.frame = view.bounds
            } else if let table = sub as? UITableView {
                table.frame = view.bounds
            }
        }
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
    func installLegacyScaling(topAligned: Bool = false) {
        // Aspect-fit the fixed-size XIB content (design size) into the safe area.
        // Using the design size keeps every screen filling the width consistently
        // and centered; content is laid out for this size.
        let base = legacyBaseSize
        let container = LegacyScalingView(frame: view.bounds)
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.baseSize = base
        container.topAligned = topAligned
        container.content.frame = CGRect(origin: .zero, size: base)

        // Fill the area the aspect-fit canvas can't cover so the fixed-size layout
        // never leaves an empty band on taller device ratios. The largest image view
        // in the XIB is the background art.
        let backgroundImage = view.subviews
            .compactMap { $0 as? UIImageView }
            .max { $0.bounds.width * $0.bounds.height < $1.bounds.width * $1.bounds.height }?
            .image
        if let backgroundImage {
            if topAligned {
                // Top-aligned screens (the menu) scale by width and leave the gap
                // *below* the content, where the art is a solid band (grass). Filling
                // that gap with the art's actual bottom-edge color continues it
                // seamlessly — an offset aspect-fill copy of the whole image instead
                // produced a "floating" duplicate band with a visible seam.
                container.backgroundColor = backgroundImage.bottomEdgeColor() ?? .white
            } else {
                // Centered screens have symmetric top/bottom gaps; an aspect-fill copy
                // of the art behind the canvas fills them with matching scenery.
                let backdrop = UIImageView(image: backgroundImage)
                backdrop.contentMode = .scaleAspectFill
                backdrop.clipsToBounds = true
                backdrop.frame = container.bounds
                backdrop.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                container.addSubview(backdrop)
            }
        }

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
