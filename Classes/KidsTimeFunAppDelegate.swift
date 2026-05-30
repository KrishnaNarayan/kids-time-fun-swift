//
//  KidsTimeFunAppDelegate.swift
//  KidsTimeFun
//
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class KidsTimeFunAppDelegate: UIResponder, UIApplicationDelegate {

    @IBOutlet var window: UIWindow?
    @IBOutlet var navController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isStatusBarHidden = true

        KidsTimeFunAppState.sharedState().resumeFromState()

        setApplicationAppearanceDefaults()

        window?.rootViewController = navController
        window?.makeKeyAndVisible()

        FloopSdkManager.sharedInstance().start(withAppKey: "a5b62509cce25acc5e397714d7c63981")

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        KidsTimeFunAppState.sharedState().flushState()
    }

    private func setApplicationAppearanceDefaults() {
        let navBar = UINavigationBar.appearance()
        navBar.backgroundColor = .clear
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()

        let tintColor = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1.0)
        navBar.tintColor = tintColor

        let shadow = NSShadow()
        shadow.shadowColor = UIColor.clear
        shadow.shadowBlurRadius = 0.0
        shadow.shadowOffset = CGSize(width: 0, height: 0)

        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: tintColor,
            .shadow: shadow
        ]
    }
}
