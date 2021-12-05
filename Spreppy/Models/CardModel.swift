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
    let numIncorrectRepetitions: Int32
    let currentStageUUID: UUID?
    let deckUUID: UUID?
    let frontText: String?
    let backText: String?

    init?(managedObject: Card) {
        guard
            let uuid = managedObject.uuid,
            let nextDuetime = managedObject.nextDueTime
        else { return nil }
        self.uuid = uuid
        nextDueTime = nextDuetime
        numCorrectRepetitions = managedObject.numCorrectRepetitions
        numIncorrectRepetitions = managedObject.numIncorrectRepetitions
        currentStageUUID = managedObject.currentStage?.uuid
        deckUUID = managedObject.deck?.uuid
        frontText = managedObject.frontText
        backText = managedObject.backText
    }

    init(
        uuid: UUID = UUID(),
        nextDueTime: Date = Date(),
        numCorrectRepetitions: Int32 = 0,
        numIncorrectRepetitions: Int32 = 0,
        currentStageUUID: UUID? = nil,
        deckUUID: UUID? = nil,
        frontText: String? = nil,
        backText: String? = nil) {
        self.uuid = uuid
        self.nextDueTime = nextDueTime
        self.numCorrectRepetitions = numCorrectRepetitions
        self.numIncorrectRepetitions = numIncorrectRepetitions
        self.currentStageUUID = currentStageUUID
        self.deckUUID = deckUUID
        self.frontText = frontText
        self.backText = backText
    }
}

extension CardModel {
    /// Whether the card is currently due
    var isDue: Bool {
        nextDueTime > Date()
    }
}
