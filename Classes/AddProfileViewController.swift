// Revised by Krishna Narayan on 5/30/26 — Used Claude to migrate to Swift, fix UI Views, remove deprecations, update for iPad, modernize for Apple UI rules.
// Revised by Krishna Narayan on 6/3/26 — Using Claude changed to 1st, 2nd, and 3rd grade levels, belts are earned not selected, added adaptive weak-drilling algorithm to rectify mistakes and build proficiency after initially providing randomized problems for activities
// Copyright 2026 Island Innovation LLC.  All rights reserved.

import UIKit

/// Create a new student: type a name and tap a fun avatar. On-device only — no
/// account, and a nickname/avatar is all that's needed (kid-friendly and avoids
/// collecting real names).
@objc(AddProfileViewController)
class AddProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {

    private let tint = UIColor(red: 0.055, green: 0.478, blue: 0.996, alpha: 1)
    private let nameField = UITextField()
    private var collection: UICollectionView!
    private var selectedAvatar = ProfileStore.avatars.randomElement() ?? "🦊"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Add Player"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))

        let isPad = UIDevice.current.userInterfaceIdiom == .pad

        nameField.placeholder = "Name"
        nameField.borderStyle = .roundedRect
        nameField.font = .systemFont(ofSize: isPad ? 26 : 20)
        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .done
        nameField.delegate = self
        nameField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameField)

        let pick = UILabel()
        pick.text = "Pick an avatar"
        pick.font = .boldSystemFont(ofSize: isPad ? 24 : 18)
        pick.textColor = .darkGray
        pick.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pick)

        let layout = UICollectionViewFlowLayout()
        let cell: CGFloat = isPad ? 86 : 64
        layout.itemSize = CGSize(width: cell, height: cell)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 12
        collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.backgroundColor = .clear
        collection.dataSource = self
        collection.delegate = self
        collection.register(AvatarCell.self, forCellWithReuseIdentifier: "a")
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)

        let side: CGFloat = isPad ? 80 : 20
        NSLayoutConstraint.activate([
            nameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: side),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -side),
            nameField.heightAnchor.constraint(equalToConstant: isPad ? 54 : 44),
            pick.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 24),
            pick.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: side),
            collection.topAnchor.constraint(equalTo: pick.bottomAnchor, constant: 12),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: side),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -side),
            collection.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameField.becomeFirstResponder()
    }

    // MARK: - Save

    @objc private func save() {
        let new = ProfileStore.shared.addProfile(name: nameField.text ?? "", avatar: selectedAvatar)
        if ProfileStore.shared.profiles.count == 1 {
            // First player — make them active and drop straight into the app.
            ProfileStore.shared.setActive(new.id)
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder(); return true
    }

    // MARK: - Avatar grid

    func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ProfileStore.avatars.count
    }

    func collectionView(_ cv: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "a", for: indexPath) as! AvatarCell
        let emoji = ProfileStore.avatars[indexPath.item]
        cell.configure(emoji: emoji, selected: emoji == selectedAvatar, tint: tint)
        return cell
    }

    func collectionView(_ cv: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAvatar = ProfileStore.avatars[indexPath.item]
        cv.reloadData()
    }
}

private class AvatarCell: UICollectionViewCell {
    private let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 14
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
    func configure(emoji: String, selected: Bool, tint: UIColor) {
        label.text = emoji
        label.font = .systemFont(ofSize: bounds.height * 0.55)
        contentView.backgroundColor = selected ? UIColor(red: 0.80, green: 0.90, blue: 1.0, alpha: 1) : UIColor(white: 0.96, alpha: 1)
        contentView.layer.borderWidth = selected ? 2.5 : 0
        contentView.layer.borderColor = tint.cgColor
    }
}
