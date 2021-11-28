//
//  CreateDeckViewModel.swift
//  Spreppy
//
//  Created by Sherry Yuan on 11/27/21.
//

import Foundation

protocol CreateDeckViewModelDelegate: AnyObject {
    func update(state: CreateDeckState)
}

struct CreateDeckState {
    var title: String?
    var summary: String?

    init(deckTitle: String? = nil, summary: String? = nil) {
        title = deckTitle
        self.summary = summary
    }

    var hasContent: Bool {
        switch (title?.isEmpty, summary?.isEmpty) {
        case (.some(false), _), (_, .some(false)):
            return true
        case (_, _):
            return false
        }
    }
}

enum CreateDeckUIEvent {
    case cancelTapped
    case saveTapped(title: String?, summary: String?)
    case summaryChanged(String?)
    case titleChanged(String?)
}

class CreateDeckViewModel {
    private(set) var state: CreateDeckState {
        didSet {
            delegate?.update(state: state)
        }
    }

    private let coordinator: Coordinator
    private let repos: Repositories
    private weak var delegate: CreateDeckViewModelDelegate?

    init(
        state: CreateDeckState = CreateDeckState(),
        coordinator: Coordinator,
        repos: Repositories,
        delegate: CreateDeckViewModelDelegate) {
        self.state = state
        self.coordinator = coordinator
        self.repos = repos
        self.delegate = delegate
    }

    func handle(_ event: CreateDeckUIEvent) {
        switch event {
        case .cancelTapped:
            guard state.hasContent else { coordinator.dismiss(); return }
            coordinator.navigate(to: .confirmCancelAlert(onConfirm: { [weak self] in
                self?.coordinator.dismiss()
            }))
        case let .saveTapped(title, summary):
            // TODO: https://github.com/rwblickhan/Spreppy/issues/42
            guard let title = title else { return }
            repos.deckRepo
                .createOrUpdate(
                    DeckModel(
                        uuid: UUID(),
                        title: title,
                        summary: summary))
            coordinator.dismiss()
        case let .summaryChanged(summary):
            state.summary = summary
        case let .titleChanged(title):
            state.title = title
        }
    }
}
