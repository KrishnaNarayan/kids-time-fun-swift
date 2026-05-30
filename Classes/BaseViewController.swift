import UIKit

@objc protocol DismissActivityDelegate: AnyObject {
    func didDismissActivity(_ sender: Any)
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
    }

    private static func solidImage(color: UIColor, size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
