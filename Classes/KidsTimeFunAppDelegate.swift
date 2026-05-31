//
//  KidsTimeFunAppDelegate.swift
//  KidsTimeFun
//
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

import UIKit

@UIApplicationMain
class KidsTimeFunAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KidsTimeFunAppState.sharedState().resumeFromState()
        setApplicationAppearanceDefaults()

        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let menuVC = MenuViewController(nibName: isIPad ? "MenuView-iPad" : "MenuView", bundle: nil)
        let nav = UINavigationController(rootViewController: menuVC)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        KidsTimeFunAppState.sharedState().flushState()
    }

    private func setApplicationAppearanceDefaults() {
        let tintColor = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1.0)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: tintColor]
        appearance.shadowColor = UIColor(white: 0.8, alpha: 1)

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = tintColor
    }
}
