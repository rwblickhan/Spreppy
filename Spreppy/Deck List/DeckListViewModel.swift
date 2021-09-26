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
    var snapshot: NSDiffableDataSourceSnapshot<Int, DeckModel>
    var isEditing: Bool

    init(
        snapshot: NSDiffableDataSourceSnapshot<Int, DeckModel> = NSDiffableDataSourceSnapshot(),
        isEditing: Bool = false
    ) {
        self.snapshot = snapshot
        self.isEditing = isEditing
    }
}

enum DeckListUIEvent {
    case viewDidLoad
    case addTapped
    case doneTapped
    case editTapped
}

class DeckListViewModel {
    private var state: DeckListState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let repository: DeckRepository
    private weak var delegate: DeckListViewModelDelegate?

    private var subscription: AnyCancellable?

    init(state: DeckListState = DeckListState(), repository: DeckRepository, delegate: DeckListViewModelDelegate) {
        self.state = state
        self.repository = repository
        self.delegate = delegate
    }

    deinit {
        subscription?.cancel()
    }

    func handle(_ event: DeckListUIEvent) {
        switch event {
        case .viewDidLoad:
            subscription = repository.fetchDeckList().sink { [weak self] deckList in
                var snapshot = NSDiffableDataSourceSnapshot<Int, DeckModel>()
                snapshot.appendSections([0])
                snapshot.appendItems(deckList)
                self?.state.snapshot = snapshot
            }
        case .addTapped:
            guard !state.isEditing else { assert(false); return }
            repository.create(DeckModel(uuid: UUID(), title: "Blah blah blah"))
        case .doneTapped:
            guard state.isEditing else { assert(false); return }
            state.isEditing = false
        case .editTapped:
            guard !state.isEditing else { assert(false); return }
            state.isEditing = true
        }
    }
}
