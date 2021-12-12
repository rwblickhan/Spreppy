//
//  SettingsViewController.swift
//  Spreppy
//
//  Created by Russell Blickhan on 12/11/21.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, SettingsViewModelDelegate {
    private var viewModel: SettingsViewModel!

    private let installBoxesLabel = UILabel()
    private let installBoxesButton = UIButton(type: .contactAdd)

    init(coordinator: Coordinator, repos: Repositories) {
        super.init(nibName: nil, bundle: nil)

        viewModel = SettingsViewModel(
            coordinator: coordinator,
            repos: repos,
            delegate: self)
    }

    // MARK: UIViewController

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init?(coder:) is unimplemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        installBoxesLabel.text = String(localized: "Install default Leitner box stages:")

        // MARK: Navigation Bar

        title = String(localized: "Settings")

        // MARK: View Hierarchy

        view.addSubview(installBoxesLabel)
        view.addSubview(installBoxesButton)

        // MARK: Layout

        installBoxesLabel.translatesAutoresizingMaskIntoConstraints = false
        installBoxesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            installBoxesLabel.leadingAnchor.constraint(
                greaterThanOrEqualToSystemSpacingAfter: view.leadingAnchor,
                multiplier: 1),
            view.trailingAnchor.constraint(
                greaterThanOrEqualToSystemSpacingAfter: installBoxesLabel.trailingAnchor,
                multiplier: 1),
            installBoxesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            installBoxesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            installBoxesButton.topAnchor.constraint(
                equalToSystemSpacingBelow: installBoxesLabel.bottomAnchor,
                multiplier: 1),
            installBoxesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        // MARK: Gesture Recognizers

        installBoxesButton.addTarget(self, action: #selector(didTapInstallBoxes), for: .touchDown)
    }

    // MARK: SettingsViewModelDelegate

    func update(state _: SettingsState) {
        // TODO:
    }

    // MARK: Actions

    @objc func didTapInstallBoxes() {
        viewModel.handle(.installBoxesTapped)
    }
}
