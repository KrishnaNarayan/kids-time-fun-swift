// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import Foundation

/// Owns the earned-belt progression: the 4-round testing ladder, the rising
/// score thresholds (yellow→black), and on-device persistence per (grade, activity)
/// of BOTH the belt earned and the current position in the ladder.
///
/// The child no longer picks difficulty or belts. Grade level (a Setting) drives
/// the clock-time complexity inside the generators; the belt for an activity is
/// *earned* by passing the ladder, tracked separately for each grade level.
///
/// The ladder position is persisted, so progress is remembered across leaving and
/// re-entering an activity (or the app): a brand-new activity begins at the untimed
/// warm-up (round 0); passing a round advances to the next, harder round; failing
/// repeats the same round; passing the final round awards the belt and resets the
/// ladder to the warm-up for the next belt.
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

    // MARK: - Persisted state: earned belt + ladder position per (grade, activity)

    private struct Progress { var earnedBelt: Int32 = -1; var currentRound: Int32 = 0 }
    private var records: [String: Progress] = [:]

    private func key(grade: Int32, activity: Int32) -> String { "\(grade)_\(activity)" }
    private func record(grade: Int32, activity: Int32) -> Progress {
        records[key(grade: grade, activity: activity)] ?? Progress()
    }

    /// The belt earned so far for this activity at this grade (-1 = none).
    func earnedBelt(grade: Int32, activity: Int32) -> Int32 {
        record(grade: grade, activity: activity).earnedBelt
    }

    func isMastered(grade: Int32, activity: Int32) -> Bool {
        earnedBelt(grade: grade, activity: activity) >= Self.maxBelt
    }

    /// The belt currently being worked toward (earnedBelt + 1), or -1 if mastered.
    func targetBelt(grade: Int32, activity: Int32) -> Int32 {
        isMastered(grade: grade, activity: activity) ? -1 : earnedBelt(grade: grade, activity: activity) + 1
    }

    // MARK: - What the next round should run (the persisted ladder position)

    struct RoundPlan {
        let questions: Int32
        let activityType: Int32   // kActTypeNumbered / kActTypeTimed
        let seconds: Int32
        let roundIndex: Int32
        let targetBelt: Int32     // belt being worked toward (-1 when mastered)
        let earnedBelt: Int32
        let mastered: Bool
    }

    func roundPlan(grade: Int32, activity: Int32) -> RoundPlan {
        let p = record(grade: grade, activity: activity)
        let mastered = p.earnedBelt >= Self.maxBelt
        // When mastered, keep free-play at the hardest round.
        let idx = mastered ? Self.lastRoundIndex : max(0, min(p.currentRound, Self.lastRoundIndex))
        let round = Self.ladder[Int(idx)]
        return RoundPlan(
            questions: round.questions,
            activityType: round.timed ? kActTypeTimed : kActTypeNumbered,
            seconds: round.seconds,
            roundIndex: idx,
            targetBelt: mastered ? -1 : p.earnedBelt + 1,
            earnedBelt: p.earnedBelt,
            mastered: mastered)
    }

    // MARK: - Evaluate a finished round (advances/persists the ladder position)

    struct RoundOutcome {
        let passed: Bool
        let sessionContinues: Bool    // true → there's another round to play (advance or repeat)
        let beltAwarded: Int32?       // non-nil → a belt was just earned
        let mastered: Bool
        let message: String
        let awardedBeltImageName: String?
    }

    @discardableResult
    func evaluateRound(grade: Int32, activity: Int32, percent: Float) -> RoundOutcome {
        var p = record(grade: grade, activity: activity)

        // Already mastered: free-play, nothing to progress.
        if p.earnedBelt >= Self.maxBelt {
            return RoundOutcome(passed: true, sessionContinues: false, beltAwarded: nil,
                                mastered: true,
                                message: "You've mastered this activity. Keep having fun!",
                                awardedBeltImageName: nil)
        }

        let target = p.earnedBelt + 1
        let needed = Self.thresholds[Int(target)]
        let neededPct = Int((needed * 100).rounded())
        let passed = percent + 0.0001 >= needed

        guard passed else {
            // Repeat the same round (position unchanged, but persist to be safe).
            save(grade: grade, activity: activity, progress: p)
            return RoundOutcome(passed: false, sessionContinues: true, beltAwarded: nil,
                                mastered: false,
                                message: "Keep practicing — you need \(neededPct)% to move on.",
                                awardedBeltImageName: nil)
        }

        if p.currentRound >= Self.lastRoundIndex {
            // Passed the final round → award the belt and reset the ladder for the
            // next belt (which begins again at the untimed warm-up).
            p.earnedBelt = target
            p.currentRound = 0
            save(grade: grade, activity: activity, progress: p)
            let nowMastered = target >= Self.maxBelt
            let name = Self.beltNames[Int(target)]
            return RoundOutcome(passed: true, sessionContinues: false, beltAwarded: target,
                                mastered: nowMastered,
                                message: nowMastered
                                    ? "You earned the \(name) — you mastered this activity!"
                                    : "You earned the \(name)!",
                                awardedBeltImageName: name)
        } else {
            // Advance to (and persist) the next round in the ladder.
            p.currentRound += 1
            save(grade: grade, activity: activity, progress: p)
            let r = Self.ladder[Int(p.currentRound)]
            let detail = r.timed
                ? "Now try \(r.questions) questions in \(r.seconds / 60) minutes."
                : "Now try \(r.questions) questions."
            return RoundOutcome(passed: true, sessionContinues: true, beltAwarded: nil,
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
        guard let dict = NSDictionary(contentsOfFile: filePath) as? [String: [NSNumber]] else { return }
        for (k, v) in dict where v.count == 2 {
            records[k] = Progress(earnedBelt: v[0].int32Value, currentRound: v[1].int32Value)
        }
    }

    private func save(grade: Int32, activity: Int32, progress: Progress) {
        records[key(grade: grade, activity: activity)] = progress
        let dict = NSMutableDictionary()
        for (k, p) in records {
            dict[k] = [NSNumber(value: p.earnedBelt), NSNumber(value: p.currentRound)]
        }
        dict.write(toFile: filePath, atomically: true)
    }
}
