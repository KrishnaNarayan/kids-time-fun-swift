//
//  KidsTimeFunAppDelegate.swift
//  KidsTimeFun
//
//  Copyright 2009-2013 NSC Partners LLC. Copyright 2014 One Step Ahead Apps, LLC. All rights reserved.
// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class KidsTimeFunAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KidsTimeFunAppState.sharedState().resumeFromState()
        configureAudioSession()
        setApplicationAppearanceDefaults()

        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        let menuVC = MenuViewController(nibName: isIPad ? "MenuView-iPad" : "MenuView", bundle: nil)
        let nav = UINavigationController(rootViewController: menuVC)

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        // This app uses a fixed, illustrated light visual design; lock the
        // interface style to light so hardcoded artwork/colors stay correct
        // regardless of the device's Dark Mode setting.
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = nav
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        KidsTimeFunAppState.sharedState().flushState()
    }

    private func configureAudioSession() {
        // Use the playback category so the spoken-time and feedback audio (the
        // whole point of this learning app) plays even when the device's
        // silent/ring switch is on. VoiceOver still ducks it automatically.
        // The in-app Sound button remains the user's on/off control.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
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
