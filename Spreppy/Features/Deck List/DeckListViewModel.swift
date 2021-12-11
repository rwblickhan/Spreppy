//
//  DeckListViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Combine
import Foundation
import UIKit

protocol DeckListViewModelDelegate: AnyObject {
    func update(state: DeckListState)
}

struct DeckListState {
    var decks: [DeckModel]
    var isEditing: Bool

    init(
        decks: [DeckModel] = [],
        isEditing: Bool = false) {
        self.decks = decks
        self.isEditing = isEditing
    }
}

enum DeckListUIEvent {
    case viewDidLoad
    case addTapped
    case doneTapped
    case editTapped
    case deleteTapped(_ row: Int)
    case deckSelected(_ row: Int)
    case deckInfoSelected(_ row: Int)
    case settingsTapped
}

class DeckListViewModel {
    private var state: DeckListState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: DeckListViewModelDelegate?

    private var subscription: AnyCancellable?

    init(
        state: DeckListState = DeckListState(),
        coordinator: Coordinator,
        repos: Repositories,
        delegate: DeckListViewModelDelegate) {
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }

    deinit {
        subscription?.cancel()
    }

    func handle(_ event: DeckListUIEvent) {
        switch event {
        case .viewDidLoad:
            subscription = repos.deckRepo.fetchDeckList().sink { [weak self] deckList in
                self?.state.decks = deckList
            }
        case .addTapped:
            guard !state.isEditing else { assert(false); return }
            coordinator.navigate(to: .createDeck)
        case .doneTapped:
            guard state.isEditing else { assert(false); return }
            state.isEditing = false
        case .editTapped:
            guard !state.isEditing else { assert(false); return }
            state.isEditing = true
        case let .deleteTapped(index):
            coordinator.navigate(to: .confirmDeleteAlert(onConfirm: { [weak self] in
                guard let self = self else { return }
                let deckModel = self.state.decks[index]
                self.repos.deckRepo.delete(deckModel)
            }))
        case let .deckSelected(row):
            guard !state.isEditing else { return }
            let deckID = state.decks[row].uuid
            coordinator.navigate(to: .deckStudy(deckID: deckID))
        case let .deckInfoSelected(row):
            guard !state.isEditing else { assert(false); return }
            let deckID = state.decks[row].uuid
            coordinator.navigate(to: .deckInfo(deckID: deckID))
        case .settingsTapped:
            coordinator.navigate(to: .settings)
        }
    }
}
