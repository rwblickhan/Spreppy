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
    var deck: DeckModel?
    var cards: [UUID: CardModel]
    var leitnerBoxes: [LeitnerBoxModel]

    init(deck: DeckModel? = nil, cards: [UUID: CardModel] = [:], leitnerBoxes: [LeitnerBoxModel] = []) {
        self.deck = deck
        self.cards = cards
        self.leitnerBoxes = leitnerBoxes
    }

    var numberOfCards: Int {
        deck?.cardUUIDs.count ?? 0
    }

    func card(at index: Int) -> CardModel? {
        guard let uuid = deck?.cardUUIDs[index] else { return nil }
        return cards[uuid]
    }
}

enum DeckStudyUIEvent {
    case viewDidLoad
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
    private let repos: Repositories
    private weak var delegate: DeckStudyViewModelDelegate?

    private var deckID: UUID

    private var deckSubscription: AnyCancellable?
    private var cardSubscriptions = [UUID: AnyCancellable?]()
    private var leitnerBoxSubscription: AnyCancellable?

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
            let fetchCards: ([UUID]) -> Void = { [weak self] cardUUIDs in
                guard let self = self else { return }
                for cardUUID in cardUUIDs {
                    let (card, cardUpdates) = self.repos.cardRepo.fetch(cardUUID)
                    self.state.cards[cardUUID] = card
                    self.cardSubscriptions[cardUUID] = cardUpdates.sink(receiveValue: { [weak self] card in
                        self?.state.cards[cardUUID] = card
                    })
                }
            }

            let (deck, deckUpdates) = repos.deckRepo.fetch(deckID)
            state.deck = deck
            fetchCards(deck?.cardUUIDs ?? [])
            deckSubscription = deckUpdates.sink(receiveValue: { [weak self] deck in
                self?.state.deck = deck
                fetchCards(deck.cardUUIDs)
            })
            leitnerBoxSubscription = repos.leitnerBoxRepo.fetchLeitnerBoxList()
                .sink(receiveValue: { [weak self] leitnerBoxes in
                    self?.state.leitnerBoxes = leitnerBoxes
                })
        case .addTapped:
            coordinator.navigate(to: .addCard(deckID: deckID))
        case let .didSwipeCard(index, direction):
            guard
                let card = state.card(at: index),
                let currentStage = state.leitnerBoxes.first(where: { card.currentStageUUID == $0.uuid })
            else { assert(false); return }
            let isCorrect: Bool
            switch direction {
            case .left: isCorrect = false
            case .right: isCorrect = true
            case .up, .down: assert(false); isCorrect = false
            }

            let newStage = LeitnerBoxSpacedRepAlgorithm.newStage(
                numIncorrectRepetitions: card.numIncorrectRepetitions,
                isCorrect: isCorrect,
                stages: state.leitnerBoxes,
                currentStage: currentStage)
            repos.cardRepo.createOrUpdate(CardModel(
                uuid: card.uuid,
                nextDueTime: Date().addingTimeInterval(newStage.delayBeforeDisplay),
                numCorrectRepetitions: isCorrect ? card.numCorrectRepetitions + 1 : 0,
                numIncorrectRepetitions: isCorrect ? 0 : card.numIncorrectRepetitions + 1,
                currentStageUUID: newStage.uuid,
                deckUUID: card.deckUUID,
                frontText: card.frontText,
                backText: card.backText))
        case .infoTapped:
            coordinator.navigate(to: .deckInfo(deckID: deckID))
        }
    }
}
