//
//  DeckStudyViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Combine
import Foundation
import Shuffle

protocol DeckStudyViewModelDelegate: AnyObject {
    func update(state: DeckStudyState)
}

struct DeckStudyState: Equatable {
    var deck: RealmDeck?

    init(deck: RealmDeck? = nil) {
        self.deck = deck
    }
}

enum DeckStudyUIEvent {
    case addTapped
    case didSwipeCard(index: Int, direction: SwipeDirection)
    case infoTapped
}

class DeckStudyViewModel {
    private(set) var state: DeckStudyState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private weak var delegate: DeckStudyViewModelDelegate?

    private let deck: RealmDeck

    init(
        deck: RealmDeck,
        state: DeckStudyState = DeckStudyState(),
        coordinator: Coordinator,
        delegate: DeckStudyViewModelDelegate) {
            self.deck = deck
        self.state = state
        self.coordinator = coordinator
        self.delegate = delegate
    }

    func handle(_ event: DeckStudyUIEvent) {
        switch event {
        case .addTapped:
            coordinator.navigate(to: .addCard(deck: deck))
        case let .didSwipeCard(index, direction):
            break
        case .infoTapped:
            coordinator.navigate(to: .deckInfo(deck: deck))
        }
    }
}
