// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import Foundation

/// One student. Each profile owns its own name, avatar, grade level, and (via
/// per-profile data folders) its own belts and adaptive-drilling history.
struct KTFProfile {
    let id: String
    var name: String
    var avatar: String      // a single emoji
    var gradeLevel: Int32
}

/// Manages the list of student profiles and which one is active. Belt progress and
/// adaptive data are stored per profile (in Documents/Profiles/<id>/), so two kids
/// sharing the app — at home or in a classroom — keep entirely separate progress.
/// Everything is on-device; no accounts, no network.
final class ProfileStore {

    static let shared = ProfileStore()
    private init() { load() }

    private(set) var profiles: [KTFProfile] = []
    private(set) var activeProfileID: String?

    /// 15 cheerful sky & nature avatars (no image assets, culturally neutral). Kept
    /// to 15 so they all fit above the keyboard on iPhone.
    static let avatars = ["☀️","🌙","⭐","🌈","☁️","⚡","🌊","🚀","🪐","🌍","🌸","🌻","🌷","🌳","🍀"]

    var activeProfile: KTFProfile? {
        guard let id = activeProfileID else { return nil }
        return profiles.first { $0.id == id }
    }

    // MARK: - Mutations

    func setActive(_ id: String) {
        guard profiles.contains(where: { $0.id == id }) else { return }
        activeProfileID = id
        save()
        refreshDependentState()
    }

    @discardableResult
    func addProfile(name: String, avatar: String) -> KTFProfile {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let profile = KTFProfile(id: UUID().uuidString,
                                 name: trimmed.isEmpty ? "Player \(profiles.count + 1)" : trimmed,
                                 avatar: avatar.isEmpty ? Self.avatars[profiles.count % Self.avatars.count] : avatar,
                                 gradeLevel: kGradeFirst)
        profiles.append(profile)
        save()
        return profile
    }

    func deleteProfile(_ id: String) {
        try? FileManager.default.removeItem(atPath: profileDir(id))
        profiles.removeAll { $0.id == id }
        if activeProfileID == id { activeProfileID = profiles.first?.id }
        save()
        refreshDependentState()
    }

    func setGrade(_ grade: Int32, for id: String) {
        guard let i = profiles.firstIndex(where: { $0.id == id }) else { return }
        profiles[i].gradeLevel = grade
        save()
    }

    /// Point the belt/adaptive stores and app state at the (new) active profile.
    private func refreshDependentState() {
        BeltProgressStore.shared.reload()
        AdaptiveDrill.shared.reload()
        KidsTimeFunAppState.sharedState().readSettings()
    }

    // MARK: - Paths

    private var documents: String {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    private var profilesRoot: String { (documents as NSString).appendingPathComponent("Profiles") }

    /// Folder holding one profile's data files (created on demand).
    func profileDir(_ id: String) -> String {
        let dir = (profilesRoot as NSString).appendingPathComponent(id)
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        return dir
    }
    var activeProfileDir: String? {
        guard let id = activeProfileID else { return nil }
        return profileDir(id)
    }

    private var indexPath: String { (documents as NSString).appendingPathComponent("KTFProfiles.plist") }

    // MARK: - Persistence

    private func load() {
        guard let dict = NSDictionary(contentsOfFile: indexPath) as? [String: Any] else { return }
        if let arr = dict["profiles"] as? [[String: Any]] {
            profiles = arr.compactMap { d in
                guard let id = d["id"] as? String, let name = d["name"] as? String else { return nil }
                return KTFProfile(id: id, name: name,
                                  avatar: d["avatar"] as? String ?? Self.avatars[0],
                                  gradeLevel: (d["grade"] as? NSNumber)?.int32Value ?? kGradeFirst)
            }
        }
        activeProfileID = dict["active"] as? String
        if activeProfileID == nil || !profiles.contains(where: { $0.id == activeProfileID }) {
            activeProfileID = profiles.first?.id
        }
    }

    private func save() {
        let arr = profiles.map { ["id": $0.id, "name": $0.name, "avatar": $0.avatar,
                                  "grade": NSNumber(value: $0.gradeLevel)] }
        let dict: [String: Any] = ["active": activeProfileID ?? "", "profiles": arr]
        (dict as NSDictionary).write(toFile: indexPath, atomically: true)
    }

    // MARK: - One-time migration from the single-user layout

    /// If the app already had (single-user) belt/adaptive data from before profiles
    /// existed, fold it into a default "Player 1" so nobody loses their belts. If
    /// there's no prior data, leave the list empty so the picker prompts to add the
    /// first player.
    func migrateLegacyDataIfNeeded() {
        guard profiles.isEmpty else { return }
        let oldBelts = (documents as NSString).appendingPathComponent(kFileBeltProgress)
        guard FileManager.default.fileExists(atPath: oldBelts) else { return }

        let settings = NSDictionary(contentsOfFile: (documents as NSString).appendingPathComponent(kFileAppSettings)) as? [String: Any] ?? [:]
        let grade = (settings[kSettingsKeyGradeLevel] as? NSNumber)?.int32Value ?? kGradeFirst

        let profile = KTFProfile(id: UUID().uuidString, name: "Player 1", avatar: Self.avatars[0], gradeLevel: grade)
        profiles = [profile]
        activeProfileID = profile.id
        save()

        let dir = profileDir(profile.id)
        try? FileManager.default.moveItem(atPath: oldBelts,
                                          toPath: (dir as NSString).appendingPathComponent("belts.plist"))
        let oldAdaptive = (documents as NSString).appendingPathComponent(kFileAdaptive)
        if FileManager.default.fileExists(atPath: oldAdaptive) {
            try? FileManager.default.moveItem(atPath: oldAdaptive,
                                              toPath: (dir as NSString).appendingPathComponent("adaptive.plist"))
        }
    }
}
