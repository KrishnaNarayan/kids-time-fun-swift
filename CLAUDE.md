# Kids Time Fun — project notes for Claude

> This file is auto-loaded each session. It holds **app-specific** context. The
> generic ObjC→Swift modernization process lives in the `/modernize-legacy-ios-app`
> slash command (and a copy at `docs/MODERNIZATION-PLAYBOOK.md`). Use this as the
> template when starting a `CLAUDE.md` for another old app.

## What this app is
A children's educational game for learning to tell time / read a clock. Originally a
legacy Objective-C iPhone app; migrated to Swift and modernized for current iOS and
iPad. Destined for the App Store (likely Kids Category).

## Identity
- **Bundle ID:** `net.islandinnovation.KidsTimeFun`
- **Display version / build:** `26.0` / `26.0`
- **Xcode project:** `KTF-v26.0.xcodeproj` (target `KidsTimeFun`)
- **Developer:** Island Innovation LLC
- **Support / Privacy contact:** `info@islandinnovation.net`
- **GitHub:** `KrishnaNarayan/kids-time-fun-swift` (remote: `git@github.com:...`)
- **Support & Privacy page:** `docs/index.html`, hosted via GitHub Pages at
  `https://krishnanarayan.github.io/kids-time-fun-swift/` (Privacy anchor `#privacy`).
  Edit `docs/index.html`, push, and Pages redeploys in ~1 min at the same URL.

## Status — already done
- Full Objective-C → Swift migration (24 classes); legacy `.m`/`.h` deleted.
- FloopSDK and other dead dependencies removed; deprecations fixed
  (`UIAlertView`→`UIAlertController`, `openURL`→`UIApplication.open`).
- `LaunchScreen.storyboard` added (unlocks native resolution).
- Aspect-fit scaling for the fixed-size XIBs across iPhone + iPad.
- HIG/App Store: `overrideUserInterfaceStyle = .light`, dead `ktf://` URL scheme
  removed, `PrivacyInfo.xcprivacy` (no collection), `AVAudioSession .ambient`,
  full VoiceOver pass, Support+Privacy page, in-app Privacy link behind a parental gate.

## Architecture specifics (so you don't relearn them)
- Screens are **fixed-frame XIBs** (320×568 iPhone / 768×1024 iPad) reparented into
  `LegacyScalingView` (in `BaseViewController.swift`) which aspect-fits them. Position
  transformed content with `.center`, never `.frame`.
- `ActivityViewController` hosts the activity child VCs via `content.addSubview(vc.view)`
  **without `addChild`** — so those children get `viewDidLoad` but **not**
  `viewWillAppear`/`viewDidAppear`. Do per-question setup in `viewDidLoad`.
- Custom-drawn `ClockView` / `SetClockView` self-describe their time to VoiceOver via
  the shared `ktfSpokenTime()` helper in `BaseViewController.swift`.
- Swipe-back is suppressed during activities (`hidesBackButton` + custom Home button)
  because dragging clock hands near the edge used to trigger an interactive pop.
- All XIB-backed classes carry `@objc(ClassName)`.

## Build / run / verify
```sh
xcodebuild -project KTF-v26.0.xcodeproj -target KidsTimeFun -sdk iphonesimulator \
  -configuration Debug CODE_SIGNING_ALLOWED=NO BUILD_DIR=/tmp/ktf-sim-build clean build
```
Then `simctl install` / `launch` and screenshot to verify. Test several iPhone **and**
iPad sizes. Quit Xcode and reopen `KTF-v26.0.xcodeproj` (not any old `KTF-v5.2`).

## Conventions
- End git commit messages with the standard `Co-Authored-By` line.
- Source-file header (per the owner's request):
  `// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.`
  `// Copyright 2026 Island Innovation LLC.  All rights reserved.`

## Known non-issues (don't "fix" these)
- Simulator can't open `mailto:` (no Mail app) — works on real devices.
- iPad Pro 13" M5 **simulator** misreports its size; the app fills correctly on real
  hardware and all other iPad simulators.

## Remaining / optional (only if asked)
- Dynamic Type and a full Auto Layout migration (large, architectural; not required
  for submission). Current fixed-canvas scaling works on all devices.
