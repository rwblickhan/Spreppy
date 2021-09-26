//
//  DeckModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Foundation

struct DeckModel: Model, Hashable {
    typealias ModelType = Deck
    
    let uuid: UUID
    let title: String
    
    init?(managedObject: Deck) {
        guard
            let uuid = managedObject.uuid,
            let title = managedObject.title
        else { return nil }
        self.uuid = uuid
        self.title = title
    }
    
    init(uuid: UUID = UUID(), title: String = "") {
        self.uuid = uuid
        self.title = title
    }
}

extension Deck {
    func configure(from deckModel: DeckModel) {
        self.uuid = deckModel.uuid
        self.title = deckModel.title
    }
}
