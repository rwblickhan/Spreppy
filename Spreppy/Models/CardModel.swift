//
//  CardModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/26/21.
//

import CoreData
import Foundation

struct CardModel: Model, Hashable {
    typealias AssociatedObjectType = Card
    static var entityName = "Card"

    let uuid: UUID
    let nextDueTime: Date
    let numCorrectRepetitions: Int32
    let deckUUID: UUID?

    init?(managedObject: Card) {
        guard
            let uuid = managedObject.uuid,
            let nextDuetime = managedObject.nextDueTime
        else { return nil }
        self.uuid = uuid
        nextDueTime = nextDuetime
        numCorrectRepetitions = managedObject.numCorrectRepetitions
        deckUUID = managedObject.uuid
    }

    init(uuid: UUID = UUID(), nextDueTime: Date = Date(), numCorrectRepetitions: Int32 = 0, deckUUID: UUID? = nil) {
        self.uuid = uuid
        self.nextDueTime = nextDueTime
        self.numCorrectRepetitions = numCorrectRepetitions
        self.deckUUID = deckUUID
    }
}

extension CardModel {
    /// Whether the card is currently due
    var isDue: Bool {
        nextDueTime > Date()
    }
}
