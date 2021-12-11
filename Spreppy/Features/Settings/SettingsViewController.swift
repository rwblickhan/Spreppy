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

    // MARK: SettingsViewModelDelegate

    func update(state _: SettingsState) {
        // TODO:
    }
}
