// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

@objc(HelpViewController)
class HelpViewController: UIViewController {

    private let appIDs = [
        1: "287877578", 2: "287880249", 3: "287882100", 4: "287884849",
        5: "290076686", 6: "300633885", 7: "318350766", 8: "380632079",
        9: "399143221", 10: "539457137", 11: "524746620", 12: "524746620",
        13: "333391557", 14: "363384622", 15: "354850603", 16: "352590964"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        installLegacyScaling()
        title = kStrHelp
    }

    @IBAction func tellaFriendButtonPressed(_ sender: UIButton) {
        let tag = sender.tag
        let urlString: String
        if let appID = appIDs[tag] {
            urlString = "http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=\(appID)&mt=8&uo=6"
        } else if tag == 17 {
            urlString = "http://linktoapp.com/nsc+partners+llc"
        } else if tag == 18 {
            urlString = "http://linktoapp.com/picpocket+books"
        } else {
            return
        }
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
