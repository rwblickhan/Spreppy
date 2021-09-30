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
    private let deckList = CurrentValueSubject<[DeckModel], Never>([])
    func fetchDeckList() -> AnyPublisher<[DeckModel], Never> {
        deckList.eraseToAnyPublisher()
    }

    func createOrUpdate(_ deckModel: DeckModel) {
        var decks = deckList.value
        if let (i, _) = deckList.value.enumerated().first(where: { $0.element.uuid == deckModel.uuid }) {
            decks[i] = deckModel
        } else {
            var decks = deckList.value
            decks.append(deckModel)
        }
        deckList.send(decks)
    }

    func setDeckList(_ decks: [DeckModel]) {
        deckList.send(decks)
    }
}

struct CardRepositorySpy: CardRepository {
    private let cardList = CurrentValueSubject<[CardModel], Never>([])
    func createOrUpdate(_ cardModel: CardModel) {
        var cards = cardList.value
        if let (i, _) = cardList.value.enumerated().first(where: { $0.element.uuid == cardModel.uuid }) {
            cards[i] = cardModel
        } else {
            var cards = cardList.value
            cards.append(cardModel)
        }
        cardList.send(cards)
    }
}
