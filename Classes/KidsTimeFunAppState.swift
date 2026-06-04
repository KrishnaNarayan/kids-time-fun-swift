// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import Foundation

class KidsTimeFunAppState: NSObject {

    private static let instance = KidsTimeFunAppState()

    @objc class func sharedState() -> KidsTimeFunAppState {
        return instance
    }

    private override init() {
        super.init()
        playerName = kDefaultPlayerName
        screen = kScrNone
        activity = kActNone
        activityType = kDefaultActivityType
        activityLevel = kDefaultActivityLevel
        gradeLevel = kDefaultGradeLevel
        maxQuestions = kDefaultMaxNumberOfQuestions
        maxTimeInSeconds = kDefaultMaxTimeInSeconds
        sizeOfTopScoreList = kDefaultSizeOfTopScoreList
        appSoundState = true
        readSettings()
    }

    var playerName: String = ""
    var screen: Int32 = 0
    var activity: Int32 = 0
    var activityType: Int32 = 0
    var activityLevel: Int32 = 0
    var gradeLevel: Int32 = 0
    var questionNumber: Int32 = 0
    var questionsRight: Int32 = 0
    var questionsWrong: Int32 = 0
    var questionsUnanswered: Int32 = 0
    var activityProgress: Int32 = 0
    var maxQuestions: Int32 = 0
    var maxTimeInSeconds: Int32 = 0
    var sizeOfTopScoreList: Int32 = 0
    var appSoundState: Bool = true

    private var settingsPath: String {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (docs as NSString).appendingPathComponent(kFileAppSettings)
    }

    private var statePath: String {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (docs as NSString).appendingPathComponent(kFileAppState)
    }

    @objc func readSettings() {
        let dict = NSDictionary(contentsOfFile: settingsPath) as? [String: Any] ?? [:]
        let nq = (dict[kSettingsKeyNumberOfQuestions] as? NSNumber)?.int32Value ?? 0
        maxQuestions = nq == 0 ? kDefaultMaxNumberOfQuestions : nq
        let nm = (dict[kSettingsKeyNumberOfMinutes] as? NSNumber)?.int32Value ?? 0
        maxTimeInSeconds = (nm == 0 ? kDefaultMaxTimeInSeconds / 60 : nm) * 60
        let al = (dict[kSettingsKeyActivityLevel] as? NSNumber)?.int32Value ?? 0
        activityLevel = al == 0 ? kDefaultActivityLevel : al
        // Grade level is the new single difficulty knob (drives clock-time increments).
        // First grade is index 0, so a missing key must fall back to the default
        // rather than being treated as "unset".
        if let g = (dict[kSettingsKeyGradeLevel] as? NSNumber)?.int32Value, !dict.isEmpty {
            gradeLevel = g
        } else {
            gradeLevel = kDefaultGradeLevel
        }
        appSoundState = dict.isEmpty ? true : ((dict[kSettingsKeyPlaySound] as? NSNumber)?.boolValue ?? true)
    }

    @objc func flushState() {
        let dict: NSDictionary = [
            "Player Name": playerName,
            "Current Screen": NSNumber(value: screen),
            "Activity": NSNumber(value: activity),
            "Activity Type": NSNumber(value: activityType),
            "Activity Level": NSNumber(value: activityLevel),
            "Question Number": NSNumber(value: questionNumber),
            "Questions Right": NSNumber(value: questionsRight),
            "Questions Wrong": NSNumber(value: questionsWrong),
            "Questions Unanswered": NSNumber(value: questionsUnanswered),
            "Activity Progress": NSNumber(value: activityProgress),
            "Max Questions": NSNumber(value: maxQuestions),
            "Max Time In Seconds": NSNumber(value: maxTimeInSeconds),
            "Size of Top Score List": NSNumber(value: sizeOfTopScoreList),
            "App Sound State": NSNumber(value: appSoundState)
        ]
        dict.write(toFile: statePath, atomically: true)
    }

    @objc func resumeFromState() {
        guard let dict = NSDictionary(contentsOfFile: statePath) as? [String: Any],
              !dict.isEmpty else { return }
        playerName = dict["Player Name"] as? String ?? playerName
        activityType = (dict["Activity Type"] as? NSNumber)?.int32Value ?? activityType
        sizeOfTopScoreList = (dict["Size of Top Score List"] as? NSNumber)?.int32Value ?? sizeOfTopScoreList
        appSoundState = (dict["App Sound State"] as? NSNumber)?.boolValue ?? appSoundState
    }
}
