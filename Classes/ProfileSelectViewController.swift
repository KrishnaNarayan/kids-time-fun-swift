// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

/// "Who's Playing?" — pick a student profile (or add one). Presented over the menu
/// at launch when there isn't a single obvious player, and any time the child taps
/// the player chip to switch. Each profile keeps its own belts, adaptive data and
/// grade level, so two kids at home (or a classroom) stay separate.
@objc(ProfileSelectViewController)
class ProfileSelectViewController: UIViewController {

    private let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    private var editingProfiles = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Who's Playing?"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = tint

        scroll.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        scroll.addSubview(stack)

        // Centered, width-capped column so player rows aren't full-screen-wide on
        // iPad (a card-like width reads much better than edge-to-edge).
        let cap = stack.widthAnchor.constraint(equalToConstant: 460)
        cap.priority = .defaultHigh
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -20),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            cap,
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rebuild()
    }

    private func rebuild() {
        // Nav buttons: Edit (only when there are profiles); Close (only when there's
        // already an active player, so first-run can't dismiss without choosing).
        let hasProfiles = !ProfileStore.shared.profiles.isEmpty
        navigationItem.rightBarButtonItem = hasProfiles
            ? UIBarButtonItem(title: editingProfiles ? "Done" : "Edit", style: .plain, target: self, action: #selector(toggleEdit))
            : nil
        navigationItem.leftBarButtonItem = (ProfileStore.shared.activeProfile != nil && !editingProfiles)
            ? UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTapped))
            : nil

        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if !hasProfiles {
            let hint = UILabel()
            hint.text = "Add a player to get started."
            hint.textColor = .darkGray
            hint.textAlignment = .center
            hint.font = .systemFont(ofSize: 18)
            hint.numberOfLines = 0
            stack.addArrangedSubview(hint)
        }

        if editingProfiles {
            let hint = UILabel()
            hint.text = ProfileStore.shared.profiles.count > 1
                ? "Tap a player to rename, or − to remove."
                : "Tap a player to rename."
            hint.textColor = .darkGray
            hint.textAlignment = .center
            hint.font = .systemFont(ofSize: 15)
            hint.numberOfLines = 0
            stack.addArrangedSubview(hint)
        }

        for (i, p) in ProfileStore.shared.profiles.enumerated() {
            stack.addArrangedSubview(profileRow(p, index: i))
        }
        if !editingProfiles {
            stack.addArrangedSubview(addRow())
        }
    }

    private var rowHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 96 : 76 }

    private func profileRow(_ p: KTFProfile, index: Int) -> UIView {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let row = UIButton(type: .system)
        row.backgroundColor = UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1)
        row.layer.cornerRadius = 18
        row.layer.borderWidth = (p.id == ProfileStore.shared.activeProfileID) ? 3 : 0
        row.layer.borderColor = tint.cgColor
        row.tag = index
        row.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
        row.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
        row.accessibilityLabel = p.name

        let avatar = UILabel()
        avatar.text = p.avatar
        avatar.font = .systemFont(ofSize: isPad ? 52 : 40)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.isUserInteractionEnabled = false
        row.addSubview(avatar)

        let name = UILabel()
        name.text = p.name
        name.font = .boldSystemFont(ofSize: isPad ? 28 : 22)
        name.textColor = .black
        name.translatesAutoresizingMaskIntoConstraints = false
        name.isUserInteractionEnabled = false
        row.addSubview(name)

        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            avatar.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            name.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 18),
            name.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])

        // Delete is offered only when more than one player exists — there's always at
        // least one player, so the app never falls back to an empty "add a player" wall.
        if editingProfiles && ProfileStore.shared.profiles.count > 1 {
            let del = UIButton(type: .system)
            del.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
            del.tintColor = .systemRed
            del.setPreferredSymbolConfiguration(.init(pointSize: isPad ? 34 : 28), forImageIn: .normal)
            del.translatesAutoresizingMaskIntoConstraints = false
            del.tag = index
            del.accessibilityLabel = "Delete \(p.name)"
            del.addTarget(self, action: #selector(deleteTapped(_:)), for: .touchUpInside)
            row.addSubview(del)
            NSLayoutConstraint.activate([
                del.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -18),
                del.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            ])
        }
        return row
    }

    private func addRow() -> UIView {
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let row = UIButton(type: .system)
        row.backgroundColor = UIColor(white: 0.95, alpha: 1)
        row.layer.cornerRadius = 18
        row.layer.borderWidth = 2
        row.layer.borderColor = UIColor(white: 0.8, alpha: 1).cgColor
        row.tintColor = tint
        row.setTitle("  ＋  Add Player", for: .normal)
        row.titleLabel?.font = .boldSystemFont(ofSize: isPad ? 26 : 21)
        row.contentHorizontalAlignment = .center
        row.heightAnchor.constraint(equalToConstant: rowHeight).isActive = true
        row.accessibilityLabel = "Add Player"
        row.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return row
    }

    // MARK: - Actions

    @objc private func rowTapped(_ sender: UIButton) {
        guard ProfileStore.shared.profiles.indices.contains(sender.tag) else { return }
        if editingProfiles {
            // In Edit mode, tapping a player renames it (so the default "Player 1"
            // can be personalized without forcing a name at first launch).
            presentRename(for: sender.tag)
            return
        }
        ProfileStore.shared.setActive(ProfileStore.shared.profiles[sender.tag].id)
        dismiss(animated: true)
    }

    private func presentRename(for index: Int) {
        guard ProfileStore.shared.profiles.indices.contains(index) else { return }
        let p = ProfileStore.shared.profiles[index]
        let alert = UIAlertController(title: "Rename Player",
                                      message: "Enter a name for this player.", preferredStyle: .alert)
        alert.addTextField {
            $0.text = p.name
            $0.placeholder = "Name"
            $0.autocapitalizationType = .words
            $0.clearButtonMode = .whileEditing
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak alert] _ in
            ProfileStore.shared.rename(p.id, to: alert?.textFields?.first?.text ?? "")
            self?.rebuild()
        })
        present(alert, animated: true)
    }

    @objc private func addTapped() {
        navigationController?.pushViewController(AddProfileViewController(), animated: true)
    }

    @objc private func toggleEdit() {
        editingProfiles.toggle()
        rebuild()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func deleteTapped(_ sender: UIButton) {
        guard ProfileStore.shared.profiles.indices.contains(sender.tag) else { return }
        let p = ProfileStore.shared.profiles[sender.tag]
        // Parental gate before erasing a child's belts.
        let a = Int.random(in: 6...9), b = Int.random(in: 6...9)
        let alert = UIAlertController(title: "Delete \(p.name)?",
            message: "This erases \(p.name)'s belts and progress.\n\nAsk a grown-up: what is \(a) × \(b)?",
            preferredStyle: .alert)
        alert.addTextField { $0.keyboardType = .numberPad; $0.placeholder = "Answer" }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self, weak alert] _ in
            if Int(alert?.textFields?.first?.text ?? "") == a * b {
                ProfileStore.shared.deleteProfile(p.id)
                if ProfileStore.shared.profiles.isEmpty { self?.editingProfiles = false }
                self?.rebuild()
            }
        })
        present(alert, animated: true)
    }
}
