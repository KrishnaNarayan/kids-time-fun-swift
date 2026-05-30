//
//  KidsTimeFunAppDelegate.swift
//  KidsTimeFun
//
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class KidsTimeFunAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KidsTimeFunAppState.sharedState().resumeFromState()
        setApplicationAppearanceDefaults()

        let menuVC = MenuViewController(nibName: "MenuView", bundle: nil)
        let nav = UINavigationController(rootViewController: menuVC)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

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
