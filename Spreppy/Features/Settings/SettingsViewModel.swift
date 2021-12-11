//
//  SettingsViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 12/11/21.
//

import Combine
import Foundation

protocol SettingsViewModelDelegate: AnyObject {
    func update(state: SettingsState)
}

struct SettingsState { }

class SettingsViewModel {
    private var state: SettingsState {
        didSet {
            delegate?.update(state: state)
        }
    }
    
    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: SettingsViewModelDelegate?

    init(
        state: SettingsState = SettingsState(),
        coordinator: Coordinator,
        repos: Repositories,
        delegate: SettingsViewModelDelegate) {
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }
}
