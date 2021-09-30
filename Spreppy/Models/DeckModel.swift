//
//  DeckModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Foundation
import CoreData

struct DeckModel: Model, Hashable {
    static let entityName: String = "Deck"
    typealias ModelType = Deck

    let uuid: UUID
    let title: String
    let cards: [CardModel]

    init?(managedObject: Deck) {
        guard
            let uuid = managedObject.uuid,
            let title = managedObject.title,
            let cards = (managedObject.cards?.sortedArray(using: []) as? [Card])?.compactMap({ CardModel(managedObject: $0) })
        else { return nil }
        self.uuid = uuid
        self.title = title
        self.cards = cards
    }

    init(uuid: UUID = UUID(), title: String = "", cards: [CardModel] = []) {
        self.uuid = uuid
        self.title = title
        self.cards = cards
    }
}

extension Deck {
    func configureAttributes(from deckModel: DeckModel) {
        uuid = deckModel.uuid
        title = deckModel.title
    }
}
