---
description: Modernize a legacy Objective-C iOS app — migrate to Swift, fix deprecations, support iPad, meet Apple HIG, and prep for App Store submission.
---

# Modernize a Legacy iOS App

You are modernizing an old Objective-C iPhone/iPad app and preparing it for current
App Store submission. Work through the phases below **in order**, adapting to the
specific app. After each phase, build and report status before moving on. Commit at
natural checkpoints (only when the user asks, or once per completed phase if they've
said to commit regularly). Always end git commit messages with the project's
standard Co-Authored-By line.

Treat this as a playbook, not a rigid script — skip steps that don't apply, and ask
the user when a decision is genuinely theirs (deployment target, bundle ID, company
name, Dark Mode vs. light-lock, Kids Category or not).

## Phase 0 — Recon (do this first, don't skip)
- Confirm it's a git repo; if not, offer `git init`.
- Inventory: list every `.m`/`.h` class, every `.xib`, the `*-Info.plist`, the
  `.xcodeproj`, and the deployment target. Note any third-party SDKs (especially
  dead/abandoned ones — ad networks, analytics, "Floop"-style services).
- Identify the `#define` constants header and the prefix `.pch`.
- Report the inventory and the plan before changing anything.

## Phase 1 — Swift migration
- Convert each `.m`/`.h` pair to a single `.swift` file, preserving behavior.
- **Add `@objc(ClassName)` to every class instantiated from a XIB** (view controllers,
  custom views, custom view subclasses) — XIBs reference ObjC class names.
- Add `@objc` to any delegate **protocols** used from a XIB or as `NSObject` selectors.
- Create/keep a **bridging header** that imports the `#define` constants header so
  Swift sees the `k...` constants. Keep that constants header and the bridging header;
  delete the rest of the `.h`/`.m` files at the end.
- Replace `main.m` with `@UIApplicationMain` (or `@main`) on the AppDelegate.
- If `MainWindow.xib`/`NSMainNibFile` causes a duplicate-AppDelegate/KVC crash, drop it
  and set up the window + root nav controller **programmatically** in
  `didFinishLaunchingWithOptions`.
- IBOutlets that may be nil at runtime: make them **optional** (`?`) — legacy code
  often force-unwraps outlets that don't exist on every device's XIB.

## Phase 2 — Project & build config (edit project.pbxproj carefully; back it up first)
- Add the new `.swift` files to the **Sources** build phase; remove the `.m` files and
  any dead-SDK file refs / framework links / build-file entries.
- Remove `VALID_ARCHS`. For simulator builds use `-sdk iphonesimulator` and
  `CODE_SIGNING_ALLOWED=NO`.
- Bump the deployment target (ask the user which — default to a current iOS).
- **CRITICAL FIX:** add a `LaunchScreen.storyboard` and set `UILaunchStoryboardName`.
  Without a launch storyboard the app is trapped in **320×568 iOS compatibility mode**
  and nothing fills modern screens. This single change unlocks native resolution and
  fixes the majority of "tiny / letterboxed / left-justified" layout complaints.
- Add `UIApplicationSceneManifest` (with `UISupportsMultipleScenes = false`) and, if
  it's a fixed-portrait game, `UIRequiresFullScreen = true`.
- Remove deprecated keys like `UIApplicationExitsOnSuspend`.

## Phase 3 — Deprecations
- `UIAlertView`/`UIActionSheet` → `UIAlertController`.
- `openURL:` → `UIApplication.shared.open(_:)`.
- `UIWebView` → `WKWebView` if present.
- Remove all calls into dead third-party SDKs; delete their code paths.

## Phase 4 — Layout for modern devices + iPad
- For fixed-frame XIB screens, use an **aspect-fit scaling container**: reparent the
  screen's subviews into a `LegacyScalingView` whose `layoutSubviews` scales the
  fixed design size (320×568 iPhone / 768×1024 iPad) into the safe area.
- **When a view has a CGAffineTransform, position it with `.center`, never `.frame`** —
  setting `.frame` on a transformed view corrupts placement (classic "not centered" bug).
- Background images: `contentMode = .scaleAspectFill` + `clipsToBounds`.
- Table screens: fill both the background image and the table to `view.bounds`.
- iPad: enlarge thin segmented controls (bigger font + height).
- If dragging inside a view (e.g. clock hands) conflicts with the swipe-back gesture:
  set `navigationItem.hidesBackButton = true` with a **custom left bar button**
  (UIKit natively suppresses the interactive pop). Toggling
  `interactivePopGestureRecognizer.isEnabled` alone is unreliable.
- Modernize the nav bar: opaque `UINavigationBarAppearance`, SF Symbols for bar buttons.

## Phase 5 — Apple HIG / App Store compliance
- **Dark Mode:** either support it with semantic colors, or for a fixed illustrated
  design lock it: `window.overrideUserInterfaceStyle = .light`.
- Remove **dead custom URL schemes** (`CFBundleURLTypes`) the app doesn't actually handle.
- **Audio:** set an `AVAudioSession` category (`.ambient` respects the mute switch and
  ducks under VoiceOver; `.playback` plays through mute). Pick per the app.
- **Privacy manifest:** add `PrivacyInfo.xcprivacy`. If the app collects nothing and
  uses no required-reason APIs, all four arrays are empty. Verify there are genuinely
  no required-reason API uses (UserDefaults, file timestamps, disk space, boot time).
- **VoiceOver:** accessibility labels on every control; custom-drawn views
  (`isAccessibilityElement = true` + a computed `accessibilityLabel`) describe what they
  show; mark decorative images `isAccessibilityElement = false`; post `.announcement`
  for transient feedback and `.screenChanged` to move focus to new content. For
  draggable custom views, use the `.allowsDirectInteraction` trait.
- **Support + Privacy Policy URLs are required** in App Store Connect. Generate a single
  self-contained `docs/index.html` (Support + Privacy sections), host via GitHub Pages
  from `/docs` (`gh api -X POST repos/OWNER/REPO/pages -f source[branch]=BRANCH -f source[path]=/docs`),
  and verify it returns 200.
- **Kids apps:** if targeting the Kids Category, gate every link that leaves the app
  (privacy policy, etc.) behind a **parental gate** (e.g. a multiplication prompt), and
  ensure no ads / no third-party analytics / no IAP. Add an in-app Privacy Policy link.

## Phase 6 — Identity & metadata (ask the user for values)
- Bundle identifier, marketing version + build number, display name.
- Optionally rename the `.xcodeproj` and the local folder / GitHub repo.
- Add the user's standard copyright/revision header to every source file if requested.

## Phase 7 — Verify
- Clean build: `xcodebuild -project X.xcodeproj -target T -sdk iphonesimulator
  -configuration Debug CODE_SIGNING_ALLOWED=NO BUILD_DIR=/tmp/build clean build`.
- Install + launch in a simulator; confirm no launch crash (`simctl launch`, check
  `launchctl list`); screenshot the main screen and read it back.
- Spot-check several **iPhone and iPad** sizes for filling/centering.
- Remind the user to test VoiceOver, `mailto:` links, and Mail-based "Tell a Friend"
  on **real hardware** — the Simulator has no Mail app and can't fully exercise VoiceOver.

## Hard-won gotchas (check these — they cost the most time)
- **No launch storyboard ⇒ 320×568 compatibility mode.** Biggest single cause of layout problems.
- **`.frame` on a transformed view breaks it.** Use `.center`.
- **`interactivePopGestureRecognizer.isEnabled = false` is unreliable** — UIKit re-enables it.
  Use `hidesBackButton` + a custom left button.
- **Child VCs added via `content.addSubview(vc.view)` (not `addChild`) never receive
  `viewWillAppear`/`viewDidAppear`.** Do per-instance setup in `viewDidLoad`, and use
  `DispatchQueue.main.async` to post accessibility focus after the view is on screen.
- **Guard score/percentage division by zero** (`answered > 0 ? right/answered : 0`) to avoid `nan%`.
- **Simulator can't open `mailto:`** (no Mail app) and may **misreport iPad Pro 13"
  dimensions** — verify such anomalies on real hardware before treating them as app bugs.
- XIBs can't find Swift classes without `@objc(ClassName)` ⇒ runtime crash on screen load.
- A stale in-tree `build/` directory can cause spurious build errors — `rm -rf build`.
