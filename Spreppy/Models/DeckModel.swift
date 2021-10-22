//
//  DeckModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import CoreData
import Foundation

struct DeckModel: Model, Hashable {
    static let entityName: String = "Deck"
    typealias ModelType = Deck

    let uuid: UUID
    let title: String
    let summary: String
    let rank: Int32
    let cardUUIDs: [UUID]

    init?(managedObject: Deck) {
        guard
            let uuid = managedObject.uuid,
            let title = managedObject.title,
            let summary = managedObject.summary,
            let cardUUIDs = (managedObject.cards?.sortedArray(using: []) as? [Card])?.compactMap(\.uuid)
        else { return nil }
        self.uuid = uuid
        self.title = title
        self.summary = summary
        rank = managedObject.rank
        self.cardUUIDs = cardUUIDs
    }

    init(uuid: UUID = UUID(), title: String = "", summary: String = "", rank: Int32 = 0, cardUUIDs: [UUID] = []) {
        self.uuid = uuid
        self.title = title
        self.summary = summary
        self.rank = rank
        self.cardUUIDs = cardUUIDs
    }
}
