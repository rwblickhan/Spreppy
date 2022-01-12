//
//  AddCardViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/4/21.
//

import Foundation

protocol AddCardViewModelDelegate: AnyObject {
    func update(state: AddCardState)
}

struct AddCardState {
    var frontText: String?
    var backText: String?

    init(frontText: String? = nil, backText: String? = nil) {
        self.frontText = frontText
        self.backText = backText
    }

    var hasContent: Bool {
        switch (frontText?.isEmpty, backText?.isEmpty) {
        case (.some(false), _), (_, .some(false)):
            return true
        case (_, _):
            return false
        }
    }
}

enum AddCardUIEvent {
    case backTextChanged(String?)
    case cancelTapped
    case frontTextChanged(String?)
    case saveTapped(frontText: String?, backText: String?)
}

class AddCardViewModel {
    private(set) var state: AddCardState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let cardRepo: Repository<RealmCard>
    private let deckRepo: Repository<RealmDeck>
    private weak var delegate: AddCardViewModelDelegate?

    private var deck: RealmDeck

    init(
        deck: RealmDeck,
        state: AddCardState = AddCardState(),
        coordinator: Coordinator,
        delegate: AddCardViewModelDelegate) {
        self.deck = deck
        self.state = state
        self.coordinator = coordinator
        self.delegate = delegate
        cardRepo = Repository()
        deckRepo = Repository()
    }

    func handle(_ event: AddCardUIEvent) {
        switch event {
        case let .backTextChanged(backText):
            state.backText = backText
        case .cancelTapped:
            guard state.hasContent else { coordinator.dismiss(); return }
            coordinator.navigate(to: .confirmCancelAlert(onConfirm: { [weak self] in
                self?.coordinator.dismiss()
            }))
        case let .frontTextChanged(frontText):
            state.frontText = frontText
        case let .saveTapped(frontText, backText):
            // TODO: https://github.com/rwblickhan/Spreppy/issues/42
            guard let frontText = frontText, let backText = backText else { return }
            let card = RealmCard(
                nextDueTime: Date(),
                numCorrectRepetitions: 0,
                numIncorrectRepetitions: 0,
                frontText: frontText,
                backText: backText)
            try! cardRepo.create(card)
            try! deckRepo.update {
                deck.cards.append(card)
            }
            coordinator.dismiss()
        }
    }
}
