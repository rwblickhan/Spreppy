//
//  DeckInfoViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/13/21.
//

import Combine
import Foundation
import RealmSwift

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
    private let deckRepo: Repository<RealmDeck>
    private weak var delegate: DeckInfoViewModelDelegate?

    private let deck: RealmDeck
    private var notificationToken: NotificationToken?

    private var subscription: AnyCancellable?

    init(
        deck: RealmDeck,
        state: DeckInfoState = DeckInfoState(),
        coordinator: Coordinator,
        delegate: DeckInfoViewModelDelegate) {
        self.state = state
        self.coordinator = coordinator
        self.delegate = delegate
        deckRepo = Repository()
        self.deck = deck
    }

    func handle(_ event: DeckInfoUIEvent) {
        switch event {
        case .viewDidLoad:
            state.title = "\(deck.title) Settings"
        }
    }
}
