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
}

enum AddCardUIEvent {
    case backTextChanged(String?)
    case cancelTapped
    case frontTextChanged(String?)
    case saveTapped(frontText: String?, backText: String?)
}

class AddCardViewModel {
    private var state: AddCardState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: AddCardViewModelDelegate?

    private var deckID: UUID

    init(
        deckID: UUID,
        state: AddCardState = AddCardState(),
        coordinator: Coordinator,
        repos: Repositories,
        delegate: AddCardViewModelDelegate) {
        self.deckID = deckID
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }

    func handle(_ event: AddCardUIEvent) {
        switch event {
        case let .backTextChanged(backText):
            state.backText = backText
        case .cancelTapped:
            // TODO: https://github.com/rwblickhan/Spreppy/issues/43
            coordinator.dismiss()
        case let .frontTextChanged(frontText):
            state.frontText = frontText
        case let .saveTapped(frontText, backText):
            // TODO: https://github.com/rwblickhan/Spreppy/issues/42
            guard let frontText = frontText, let backText = backText else { return }
            repos.cardRepo
                .createOrUpdate(
                    CardModel(
                        uuid: UUID(),
                        numCorrectRepetitions: 0,
                        deckUUID: deckID,
                        frontText: frontText,
                        backText: backText))
            coordinator.dismiss()
        }
    }
}
