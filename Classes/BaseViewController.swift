import UIKit

@objc protocol DismissActivityDelegate: AnyObject {
    func didDismissActivity(_ sender: Any)
}

@objc(BaseViewController)
class BaseViewController: UIViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /// Give an answer segmented control an opaque, high-contrast appearance so the
    /// options stay readable over the colored activity backgrounds.
    func styleChoices(_ control: UISegmentedControl?) {
        guard let control = control else { return }
        control.backgroundColor = UIColor.white.withAlphaComponent(0.92)
        control.selectedSegmentTintColor = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1.0)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
}
