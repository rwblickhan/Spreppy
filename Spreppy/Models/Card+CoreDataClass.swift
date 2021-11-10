//
//  Card+CoreDataClass.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/24/21.
//
//

import CoreData
import Foundation

@objc(Card)
public class Card: NSManagedObject, ModelObject {
    typealias AssociatedModel = CardModel

    func configure(from model: CardModel, managedObjectContext: NSManagedObjectContext) {
        uuid = model.uuid
        nextDueTime = model.nextDueTime
        numCorrectRepetitions = model.numCorrectRepetitions
        numIncorrectRepetitions = model.numIncorrectRepetitions
        frontText = model.frontText
        backText = model.backText
        if let currentStageUUID = model.currentStageUUID {
            let currentStageRequest = NSFetchRequest<LeitnerBox>(entityName: LeitnerBoxModel.entityName)
            currentStageRequest.predicate = NSPredicate(format: "uuid == %@", currentStageUUID.uuidString)
            currentStageRequest.fetchLimit = 1
            if let fetchedStage = try? managedObjectContext.fetch(currentStageRequest).first {
                currentStage = fetchedStage
            }
        } else {
            currentStage = nil
        }
        if let deckUUID = model.deckUUID {
            let deckFetchRequest = NSFetchRequest<Deck>(entityName: DeckModel.entityName)
            deckFetchRequest.predicate = NSPredicate(format: "uuid == %@", deckUUID.uuidString)
            deckFetchRequest.fetchLimit = 1
            if let fetchedDeck = try? managedObjectContext.fetch(deckFetchRequest).first {
                deck = fetchedDeck
            }
        } else {
            deck = nil
        }
    }
}
