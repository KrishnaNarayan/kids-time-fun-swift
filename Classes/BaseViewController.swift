import UIKit

@objc protocol DismissActivityDelegate: AnyObject {
    func didDismissActivity(_ sender: Any)
}

class BaseViewController: UIViewController {
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
