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
    case deckSelected(_ row: Int)
}

class DeckListViewModel {
    private var state: DeckListState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let repos: Repositories
    private weak var delegate: DeckListViewModelDelegate?

    private var subscription: AnyCancellable?

    init(state: DeckListState = DeckListState(), repos: Repositories, delegate: DeckListViewModelDelegate) {
        self.state = state
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
            repos.deckRepo.createOrUpdate(DeckModel(title: "Blah blah blah"))
        case .doneTapped:
            guard state.isEditing else { assert(false); return }
            state.isEditing = false
        case .editTapped:
            guard !state.isEditing else { assert(false); return }
            state.isEditing = true
        case let .deckSelected(row):
            guard !state.isEditing else { return }
            let deck = state.decks[row]
            let cardModel = CardModel(deck: deck)
            repos.cardRepo.createOrUpdate(cardModel)
        }
    }
}
