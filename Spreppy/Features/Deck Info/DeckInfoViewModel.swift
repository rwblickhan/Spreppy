//
//  DeckInfoViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/13/21.
//

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
            // TODO: https://github.com/rwblickhan/Spreppy/issues/17
            // Update this to the name of the deck
            state.title = deckID.uuidString
        }
    }
}
