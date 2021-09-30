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
    let cardUUIDs: [UUID]

    init?(managedObject: Deck) {
        guard
            let uuid = managedObject.uuid,
            let title = managedObject.title,
            let cardUUIDs = (managedObject.cards?.sortedArray(using: []) as? [Card])?.compactMap(\.uuid)
        else { return nil }
        self.uuid = uuid
        self.title = title
        self.cardUUIDs = cardUUIDs
    }

    init(uuid: UUID = UUID(), title: String = "", cardUUIDs: [UUID] = []) {
        self.uuid = uuid
        self.title = title
        self.cardUUIDs = cardUUIDs
    }
}
