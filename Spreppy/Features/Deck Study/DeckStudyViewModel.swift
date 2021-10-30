//
//  DeckStudyViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Combine
import Foundation

protocol DeckStudyViewModelDelegate: AnyObject {
    func update(state: DeckStudyState)
}

struct DeckStudyState {
    var deck: DeckModel?

    init(deck: DeckModel? = nil) {
        self.deck = deck
    }
}

enum DeckStudyUIEvent {
    case viewDidLoad
    case addTapped
}

class DeckStudyViewModel {
    private(set) var state: DeckStudyState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: DeckStudyViewModelDelegate?

    private var deckID: UUID

    private var deckSubscription: AnyCancellable?

    init(
        deckID: UUID,
        state: DeckStudyState = DeckStudyState(),
        coordinator: Coordinator,
        repos: Repositories,
        delegate: DeckStudyViewModelDelegate) {
        self.deckID = deckID
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }

    func handle(_ event: DeckStudyUIEvent) {
        switch event {
        case .viewDidLoad:
            let (deck, deckUpdates) = repos.deckRepo.fetch(deckID)
            state.deck = deck
            deckSubscription = deckUpdates.sink(receiveValue: { [weak self] deck in
                self?.state.deck = deck
            })
        case .addTapped:
            // TODO: https://github.com/rwblickhan/Spreppy/issues/18
            // Stub out a UI for this
            repos.cardRepo.createOrUpdate(CardModel(deckUUID: deckID, frontText: "What is the Answer to the Question of Life, the Universe, and Everything?", backText: "42"))
        }
    }
}
