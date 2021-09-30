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
    let deckUUID: UUID?
    
    init?(managedObject: Card) {
        guard
            let uuid = managedObject.uuid,
            let nextDuetime = managedObject.nextDueTime
        else { return nil }
        self.uuid = uuid
        self.nextDueTime = nextDuetime
        self.numCorrectRepetitions = managedObject.numCorrectRepetitions
        self.deckUUID = managedObject.uuid
    }
    
    init(uuid: UUID = UUID(), nextDueTime: Date = Date(), numCorrectRepetitions: Int32 = 0, deckUUID: UUID? = nil) {
        self.uuid = uuid
        self.nextDueTime = nextDueTime
        self.numCorrectRepetitions = numCorrectRepetitions
        self.deckUUID = deckUUID
    }
}
