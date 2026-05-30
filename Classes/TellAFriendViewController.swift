import UIKit
import MessageUI

class TellAFriendViewController: UIViewController, MFMailComposeViewControllerDelegate {

    private var message: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        title = kStrTellAFriend
    }

    @IBAction func tellAFriend(_ sender: Any) {
        if MFMailComposeViewController.canSendMail() {
            displayComposerSheet()
        } else {
            launchMailAppOnDevice()
        }
    }

    func displayComposerSheet() {
        let picker = MFMailComposeViewController()
        picker.mailComposeDelegate = self
        picker.setSubject("Kids Time Fun App")
        picker.setMessageBody("Please try this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766", isHTML: false)
        present(picker, animated: true)
    }

    func launchMailAppOnDevice() {
        let base = "mailto:?subject=Learn To Tell Time--Kids iPhone/iPod/iPad App!&body=Please try this really cool app:  http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=318350766"
        guard let encoded = base.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else { return }
        UIApplication.shared.openURL(url)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                                didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .saved:   message = "Your information saved successfully"
        case .sent:    message = "Your friends were informed about this application"
        case .failed:  message = "Sorry, I couldn't inform your friend. Try again"
        default:       message = ""
        }
        dismiss(animated: true) {
            if !self.message.isEmpty {
                let av = UIAlertView(title: "Tell A Friend", message: self.message, delegate: nil, cancelButtonTitle: "OK")
                av.show()
            }
        }
    }
}
