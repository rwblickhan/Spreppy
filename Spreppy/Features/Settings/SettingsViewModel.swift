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

struct SettingsState {}

enum SettingsUIEvent {
    case installBoxesTapped
}

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

    func handle(_ event: SettingsUIEvent) {
        switch event {
        case .installBoxesTapped:
            let apprentice1BoxUUID = UUID()
            let apprentice2BoxUUID = UUID()
            let apprentice3BoxUUID = UUID()
            let apprentice4BoxUUID = UUID()
            let guru1BoxUUID = UUID()
            let guru2BoxUUID = UUID()
            let masterBoxUUID = UUID()
            let enlightenedBoxUUID = UUID()
            let apprentice1Box = LeitnerBoxModel(
                uuid: apprentice1BoxUUID,
                title: String(localized: "Apprentice 1"),
                delayBeforeDisplay: 0,
                previousStageUUID: nil,
                nextStageUUID: apprentice2BoxUUID)
            let apprentice2Box = LeitnerBoxModel(
                uuid: apprentice2BoxUUID,
                title: String(localized: "Apprentice 2"),
                delayBeforeDisplay: 4 * 60 * 60,
                previousStageUUID: apprentice1BoxUUID,
                nextStageUUID: apprentice3BoxUUID)
            let apprentice3Box = LeitnerBoxModel(
                uuid: apprentice3BoxUUID,
                title: String(localized: "Apprentice 3"),
                delayBeforeDisplay: 8 * 60 * 60,
                previousStageUUID: apprentice2BoxUUID,
                nextStageUUID: apprentice4BoxUUID)
            let apprentice4Box = LeitnerBoxModel(
                uuid: apprentice4BoxUUID,
                title: String(localized: "Apprentice 4"),
                delayBeforeDisplay: 24 * 60 * 60,
                previousStageUUID: apprentice3BoxUUID,
                nextStageUUID: guru1BoxUUID)
            let guru1Box = LeitnerBoxModel(
                uuid: guru1BoxUUID,
                title: String(localized: "Guru 1"),
                delayBeforeDisplay: 2 * 24 * 60 * 60,
                previousStageUUID: apprentice4BoxUUID,
                nextStageUUID: guru2BoxUUID)
            let guru2Box = LeitnerBoxModel(
                uuid: guru2BoxUUID,
                title: String(localized: "Guru 2"),
                delayBeforeDisplay: 7 * 24 * 60 * 60,
                previousStageUUID: guru1BoxUUID,
                nextStageUUID: masterBoxUUID)
            let masterBox = LeitnerBoxModel(
                uuid: masterBoxUUID,
                title: String(localized: "Master"),
                delayBeforeDisplay: 2 * 7 * 24 * 60 * 60,
                previousStageUUID: guru2BoxUUID,
                nextStageUUID: enlightenedBoxUUID)
            let enlightenedBox = LeitnerBoxModel(
                uuid: enlightenedBoxUUID,
                title: String(localized: "Enlightened"),
                delayBeforeDisplay: 4 * 7 * 24 * 60 * 60,
                previousStageUUID: masterBoxUUID,
                nextStageUUID: nil)
        }
    }
}
