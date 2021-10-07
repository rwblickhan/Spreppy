//
//  DeckStudyViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/6/21.
//

import Foundation

protocol DeckStudyViewModelDelegate: AnyObject {
    func update(state: DeckStudyState)
}

struct DeckStudyState {
    var title: String
    
    init(title: String = "") {
        self.title = title
    }
}

enum DeckStudyUIEvent {
    case viewDidLoad
    case addTapped
}

class DeckStudyViewModel {
    private var state: DeckStudyState {
        didSet {
            delegate?.update(state: state)
        }
    }
    
    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: DeckStudyViewModelDelegate?
    
    private var deckID: UUID
    
    init(deckID: UUID, state: DeckStudyState = DeckStudyState(), coordinator: Coordinator, repos: Repositories, delegate: DeckStudyViewModelDelegate) {
        self.deckID = deckID
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }
    
    func handle(_ event: DeckStudyUIEvent) {
        switch event {
        case .viewDidLoad:
            // TODO update this to the name of the deck
            state.title = deckID.uuidString
        case .addTapped:
            // TODO add a UI for this
            repos.cardRepo.createOrUpdate(CardModel(deckUUID: deckID))
        }
    }
}
