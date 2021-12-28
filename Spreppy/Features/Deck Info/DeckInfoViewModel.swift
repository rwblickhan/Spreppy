//
//  DeckInfoViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/13/21.
//

import Combine
import Foundation

protocol DeckInfoViewModelDelegate: AnyObject {
    func update(state: DeckInfoState)
}

struct DeckInfoState {
    var title: String

    init(title: String = "") {
        self.title = title
    }
}

enum DeckInfoUIEvent {
    case viewDidLoad
}

class DeckInfoViewModel {
    private var state: DeckInfoState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: DeckInfoViewModelDelegate?

    private var deckID: UUID

    private var subscription: AnyCancellable?

    init(
        deckID: UUID,
        state: DeckInfoState = DeckInfoState(),
        coordinator: Coordinator,
        repos: Repositories,
        delegate: DeckInfoViewModelDelegate) {
        self.deckID = deckID
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }

    func handle(_ event: DeckInfoUIEvent) {
        switch event {
        case .viewDidLoad:
            let (deck, deckUpdates) = repos.deckRepo.fetch(deckID)
            state.title = "\(deck?.title ?? "Deck") Settings"
            subscription = deckUpdates.sink(receiveValue: { [weak self] deck in
                self?.state.title = "\(deck.title) Settings"
            })
        }
    }
}
