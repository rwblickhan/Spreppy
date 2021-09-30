//
//  CardModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/26/21.
//

import Foundation
import CoreData

struct CardModel: Model, Hashable {
    typealias ModelType = Card
    static var entityName = "Card"
    
    let uuid: UUID
    let nextDueTime: Date
    let numCorrectRepetitions: Int32
    let deck: DeckModel?
    
    init?(managedObject: Card) {
        guard
            let uuid = managedObject.uuid,
            let nextDuetime = managedObject.nextDueTime
        else { return nil }
        self.uuid = uuid
        self.nextDueTime = nextDuetime
        self.numCorrectRepetitions = managedObject.numCorrectRepetitions
        self.deck = managedObject.deck.flatMap({ DeckModel(managedObject: $0) })
    }
    
    init(uuid: UUID = UUID(), nextDueTime: Date = Date(), numCorrectRepetitions: Int32 = 0, deck: DeckModel? = nil) {
        self.uuid = uuid
        self.nextDueTime = nextDueTime
        self.numCorrectRepetitions = numCorrectRepetitions
        self.deck = deck
    }
}

extension Card {
    func configureAttributes(from cardModel: CardModel) {
        uuid = cardModel.uuid
        nextDueTime = cardModel.nextDueTime
        numCorrectRepetitions = cardModel.numCorrectRepetitions
    }
}
