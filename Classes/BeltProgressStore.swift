// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import Foundation

/// Owns the earned-belt progression: the 4-round testing ladder, the rising
/// score thresholds (yellow→black), and on-device persistence of the belt earned
/// per (grade, activity).
///
/// The child no longer picks difficulty or belts. Grade level (a Setting) drives
/// the clock-time complexity inside the generators; the belt for an activity is
/// *earned* by passing the ladder, and is tracked separately for each grade level.
///
/// Each time the child enters an activity the ladder starts fresh at Round 0 (the
/// 10-question, untimed warm-up). Passing a round advances to the next, harder
/// round in the same session; failing repeats the same round. Only the earned
/// belt is saved — the mid-ladder position is per-session and never persisted, so
/// the warm-up always comes first and there is no time pressure to begin with.
final class BeltProgressStore {

    static let shared = BeltProgressStore()
    private init() { load() }

    // MARK: - Ladder definition

    struct Round { let questions: Int32; let timed: Bool; let seconds: Int32 }

    /// One belt attempt = these four rounds, run in order. Round 0 is an untimed
    /// warm-up; the later rounds add a time limit.
    static let ladder: [Round] = [
        Round(questions: 10, timed: false, seconds: 0),
        Round(questions: 10, timed: true,  seconds: 180),
        Round(questions: 10, timed: true,  seconds: 120),
        Round(questions: 20, timed: true,  seconds: 180)
    ]

    /// Passing score required for each belt, indexed by belt
    /// (0 yellow, 1 green, 2 red, 3 black).
    static let thresholds: [Float] = [0.50, 0.70, 0.90, 1.00]

    static let beltNames = ["Yellow Belt", "Green Belt", "Red Belt", "Black Belt"]
    static var lastRoundIndex: Int32 { Int32(ladder.count) - 1 }
    static var maxBelt: Int32 { Int32(beltNames.count) - 1 }

    // MARK: - Persisted state: earned belt per (grade, activity)

    private var earned: [String: Int32] = [:]
    private func key(grade: Int32, activity: Int32) -> String { "\(grade)_\(activity)" }

    /// The belt earned so far for this activity at this grade (-1 = none).
    func earnedBelt(grade: Int32, activity: Int32) -> Int32 {
        earned[key(grade: grade, activity: activity)] ?? -1
    }

    func isMastered(grade: Int32, activity: Int32) -> Bool {
        earnedBelt(grade: grade, activity: activity) >= Self.maxBelt
    }

    /// The belt currently being worked toward (earnedBelt + 1), or -1 if mastered.
    func targetBelt(grade: Int32, activity: Int32) -> Int32 {
        isMastered(grade: grade, activity: activity) ? -1 : earnedBelt(grade: grade, activity: activity) + 1
    }

    // MARK: - What a given round of the session should run

    struct RoundPlan {
        let questions: Int32
        let activityType: Int32   // kActTypeNumbered / kActTypeTimed
        let seconds: Int32
        let targetBelt: Int32     // belt being worked toward (-1 when mastered)
        let earnedBelt: Int32
        let mastered: Bool
    }

    func roundPlan(grade: Int32, activity: Int32, roundIndex: Int32) -> RoundPlan {
        let mastered = isMastered(grade: grade, activity: activity)
        let idx = max(0, min(roundIndex, Self.lastRoundIndex))
        let round = Self.ladder[Int(idx)]
        return RoundPlan(
            questions: round.questions,
            activityType: round.timed ? kActTypeTimed : kActTypeNumbered,
            seconds: round.seconds,
            targetBelt: targetBelt(grade: grade, activity: activity),
            earnedBelt: earnedBelt(grade: grade, activity: activity),
            mastered: mastered)
    }

    // MARK: - Evaluate a finished round

    struct RoundOutcome {
        let passed: Bool
        let nextRoundIndex: Int32?    // non-nil → continue the session at this round
        let beltAwarded: Int32?       // non-nil → a belt was just earned
        let mastered: Bool
        let message: String
        let awardedBeltImageName: String?
    }

    /// Record a finished round's score, advance/repeat/award accordingly, persist
    /// any newly earned belt, and return what to tell the child.
    @discardableResult
    func evaluateRound(grade: Int32, activity: Int32, roundIndex: Int32, percent: Float) -> RoundOutcome {

        // Already mastered: free-play, nothing to progress.
        if isMastered(grade: grade, activity: activity) {
            return RoundOutcome(passed: true, nextRoundIndex: nil, beltAwarded: nil,
                                mastered: true,
                                message: "You've mastered this activity. Keep having fun!",
                                awardedBeltImageName: nil)
        }

        let target = targetBelt(grade: grade, activity: activity)
        let needed = Self.thresholds[Int(target)]
        let neededPct = Int((needed * 100).rounded())
        let passed = percent + 0.0001 >= needed

        guard passed else {
            // Repeat the same round.
            return RoundOutcome(passed: false, nextRoundIndex: roundIndex, beltAwarded: nil,
                                mastered: false,
                                message: "Keep practicing — you need \(neededPct)% to move on.",
                                awardedBeltImageName: nil)
        }

        if roundIndex >= Self.lastRoundIndex {
            // Passed the final round → award the belt for this grade/activity.
            earned[key(grade: grade, activity: activity)] = target
            save()
            let nowMastered = target >= Self.maxBelt
            let name = Self.beltNames[Int(target)]
            return RoundOutcome(passed: true, nextRoundIndex: nil, beltAwarded: target,
                                mastered: nowMastered,
                                message: nowMastered
                                    ? "You earned the \(name) — you mastered this activity!"
                                    : "You earned the \(name)!",
                                awardedBeltImageName: name)
        } else {
            // Advance to the next round in the ladder.
            let next = roundIndex + 1
            let r = Self.ladder[Int(next)]
            let detail = r.timed
                ? "Now try \(r.questions) questions in \(r.seconds / 60) minutes."
                : "Now try \(r.questions) questions."
            return RoundOutcome(passed: true, nextRoundIndex: next, beltAwarded: nil,
                                mastered: false,
                                message: "Great work! \(detail)",
                                awardedBeltImageName: nil)
        }
    }

    // MARK: - Persistence

    private var filePath: String {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (docs as NSString).appendingPathComponent(kFileBeltProgress)
    }

    private func load() {
        guard let dict = NSDictionary(contentsOfFile: filePath) as? [String: NSNumber] else { return }
        for (k, v) in dict { earned[k] = v.int32Value }
    }

    private func save() {
        let dict = NSMutableDictionary()
        for (k, v) in earned { dict[k] = NSNumber(value: v) }
        dict.write(toFile: filePath, atomically: true)
    }
}
