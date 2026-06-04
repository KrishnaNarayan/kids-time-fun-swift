// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import Foundation

/// On-device adaptive "weak-area drilling" for the time-telling skill.
///
/// This is deliberately NOT a neural network or a cloud model — it's a small,
/// explainable mastery model that runs entirely on the device (Kids-Category /
/// COPPA safe, no network, free, instant). It "keeps track of mistakes", but with
/// smoothing, weighted sampling, exploration and decay so it actually teaches:
///
///  • Skill buckets = the minute value the child must read/set, sized to their
///    grade (1st: :00/:30, 2nd: :00/:15/:30/:45, 3rd: every 5 min). Each activity
///    is tracked separately.
///  • Per bucket we keep seen/correct and a Laplace-smoothed accuracy
///    p = (correct+1)/(seen+2); weakness = 1 − p (unseen buckets start neutral).
///  • The first questions for an activity are random (warm-up — no data yet).
///    After that ~70% of questions are sampled weighted toward weak buckets
///    (weakness²), the rest stay random for variety, never repeating back-to-back.
///  • A sliding-window cap lets recent performance dominate, so once a bucket is
///    mastered its weakness fades and drilling moves on — building proficiency.
final class AdaptiveDrill {

    static let shared = AdaptiveDrill()
    private init() { load() }

    // MARK: - Tunables
    private let warmupSamples = 6     // stay fully random until this many answers logged
    private let adaptiveProb = 0.70   // chance a post-warm-up question targets a weak bucket
    private let countCap = 20         // sliding-window cap so improvement erases old weakness

    // MARK: - State
    private struct Stat { var seen: Int; var correct: Int }
    private var stats: [String: Stat] = [:]          // key "grade_activity_minute"
    private var lastMinute: [String: Int] = [:]      // in-memory: avoid back-to-back repeats

    private func key(_ g: Int32, _ a: Int32, _ m: Int) -> String { "\(g)_\(a)_\(m)" }
    private func akey(_ g: Int32, _ a: Int32) -> String { "\(g)_\(a)" }

    /// The minute values reachable at a given grade increment, e.g. 15 → 0,15,30,45.
    func candidateMinutes(interval: Int) -> [Int] {
        guard interval > 0 else { return [0] }
        return Array(stride(from: 0, through: 59, by: interval))
    }

    // MARK: - Question selection

    /// A weak minute value to drill next, or nil to pick randomly (warm-up / variety).
    func nextTargetMinute(grade: Int32, activity: Int32, interval: Int) -> Int? {
        let candidates = candidateMinutes(interval: interval)
        guard candidates.count > 1 else { return nil }

        let totalSeen = candidates.reduce(0) { $0 + (stats[key(grade, activity, $1)]?.seen ?? 0) }
        if totalSeen < warmupSamples { return nil }                 // still randomizing
        if Double.random(in: 0..<1) >= adaptiveProb { return nil }  // keep variety

        var weights: [Double] = []
        for m in candidates {
            let s = stats[key(grade, activity, m)]
            let seen = Double(s?.seen ?? 0)
            let correct = Double(s?.correct ?? 0)
            let proficiency = (correct + 1) / (seen + 2)   // Laplace-smoothed (neutral 0.5)
            let weakness = 1 - proficiency                 // 0…1
            let exploration = seen < 2 ? 0.3 : 0.0         // nudge rarely-seen buckets
            weights.append(weakness * weakness + exploration + 0.02)
        }
        let pick = weightedPick(candidates, weights: weights, avoid: lastMinute[akey(grade, activity)])
        lastMinute[akey(grade, activity)] = pick
        return pick
    }

    private func weightedPick(_ items: [Int], weights: [Double], avoid: Int?) -> Int {
        var idxs = Array(items.indices)
        if let a = avoid, items.count > 1, let ai = items.firstIndex(of: a) {
            idxs.removeAll { $0 == ai }
        }
        let total = idxs.reduce(0.0) { $0 + weights[$1] }
        guard total > 0 else { return items[idxs.randomElement() ?? 0] }
        var r = Double.random(in: 0..<total)
        for i in idxs {
            r -= weights[i]
            if r <= 0 { return items[i] }
        }
        return items[idxs.last ?? 0]
    }

    // MARK: - Recording

    /// Log the outcome of one question (record the FIRST attempt per question).
    func record(grade: Int32, activity: Int32, minute: Int, correct: Bool) {
        let k = key(grade, activity, minute)
        var s = stats[k] ?? Stat(seen: 0, correct: 0)
        s.seen += 1
        if correct { s.correct += 1 }
        if s.seen >= countCap {                       // sliding window: recent perf dominates
            s.seen = (s.seen + 1) / 2
            s.correct = (s.correct + 1) / 2
        }
        stats[k] = s
        save()
    }

    // MARK: - Persistence

    private var filePath: String {
        let docs = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (docs as NSString).appendingPathComponent(kFileAdaptive)
    }

    private func load() {
        guard let dict = NSDictionary(contentsOfFile: filePath) as? [String: [NSNumber]] else { return }
        for (k, v) in dict where v.count == 2 {
            stats[k] = Stat(seen: v[0].intValue, correct: v[1].intValue)
        }
    }

    private func save() {
        let dict = NSMutableDictionary()
        for (k, s) in stats { dict[k] = [NSNumber(value: s.seen), NSNumber(value: s.correct)] }
        dict.write(toFile: filePath, atomically: true)
    }
}
