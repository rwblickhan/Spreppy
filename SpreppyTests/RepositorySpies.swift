//
//  RepositorySpies.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 9/29/21.
//

import Combine
import Foundation
@testable import Spreppy

struct RepositorySpies: Repositories {
    let deckRepoSpy = DeckRepositorySpy()
    let cardRepoSpy = CardRepositorySpy()

    var deckRepo: DeckRepository {
        deckRepoSpy
    }

    var cardRepo: CardRepository {
        cardRepoSpy
    }
}

struct DeckRepositorySpy: DeckRepository {
    let deckList = CurrentValueSubject<[DeckModel], Never>([])
    func fetchDeckList() -> AnyPublisher<[DeckModel], Never> {
        deckList.eraseToAnyPublisher()
    }

    func fetchDeck(_ deckID: UUID) -> (DeckModel?, AnyPublisher<DeckModel, Never>) {
        let deck = deckList.value.first(where: { $0.uuid == deckID })
        let publisher = deckList.compactMap { $0.first(where: { $0.uuid == deckID }) }.eraseToAnyPublisher()
        return (deck, publisher)
    }

    func createOrUpdate(_ deckModel: DeckModel) {
        var decks = deckList.value
        if let (i, _) = deckList.value.enumerated().first(where: { $0.element.uuid == deckModel.uuid }) {
            decks[i] = deckModel
        } else {
            decks.append(deckModel)
        }
        deckList.send(decks)
    }

    func delete(_ deckModel: DeckModel) {
        var decks = deckList.value
        decks.removeAll(where: { $0 == deckModel })
        deckList.send(decks)
    }

    func setDeckList(_ decks: [DeckModel]) {
        deckList.send(decks)
    }
}

struct CardRepositorySpy: CardRepository {
    let cardList = CurrentValueSubject<[CardModel], Never>([])

    func fetchCard(_ cardID: UUID) -> (CardModel?, AnyPublisher<CardModel, Never>) {
        let card = cardList.value.first(where: { $0.uuid == cardID })
        let publisher = cardList.compactMap { $0.first(where: { $0.uuid == cardID }) }.eraseToAnyPublisher()
        return (card, publisher)
    }

    func createOrUpdate(_ cardModel: CardModel) {
        var cards = cardList.value
        if let (i, _) = cardList.value.enumerated().first(where: { $0.element.uuid == cardModel.uuid }) {
            cards[i] = cardModel
        } else {
            cards.append(cardModel)
        }
        cardList.send(cards)
    }
}
