//
//  DeckListViewModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Combine
import Foundation
import UIKit
import RealmSwift

protocol DeckListViewModelDelegate: AnyObject {
    func update(state: DeckListState)
}

struct DeckListState {
    var decks: [RealmDeck]
    var isEditing: Bool

    init(
        decks: [RealmDeck] = [],
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
}

class DeckListViewModel {
    private var state: DeckListState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let deckRepo: Repository<RealmDeck>
    private weak var delegate: DeckListViewModelDelegate?

    private var notificationToken: NotificationToken?

    init(
        state: DeckListState = DeckListState(),
        coordinator: Coordinator,
        delegate: DeckListViewModelDelegate) {
        self.state = state
        self.coordinator = coordinator
        self.delegate = delegate
            self.deckRepo = Repository()
    }

    deinit {
        notificationToken?.invalidate()
    }

    func handle(_ event: DeckListUIEvent) {
        switch event {
        case .viewDidLoad:
            notificationToken = deckRepo.fetch().observe { [weak self] changes in
                switch changes {
                case let .initial(results):
                    self?.state.decks = results.filter { _ in true }
                case let .update(results, _, _, _):
                    self?.state.decks = results.filter { _ in true }
                case let .error(error):
                    // TODO
                    fatalError()
                }
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
                let deck = self.state.decks[index]
                try! self.deckRepo.delete(deck)
            }))
        case let .deckSelected(row):
            guard !state.isEditing else { return }
            let deck = state.decks[row]
            coordinator.navigate(to: .deckStudy(deck: deck))
        }
    }
}
