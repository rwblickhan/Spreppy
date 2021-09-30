//
//  CardRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/26/21.
//

import CoreData
import Foundation

protocol CardRepository {
    func createOrUpdate(_ cardModel: CardModel)
}

class CardCoreDataRepository: CardRepository {
    private let persistentContainer: NSPersistentContainer

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }

    func createOrUpdate(_ cardModel: CardModel) {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Card>(entityName: CardModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", cardModel.uuid.uuidString)
        fetchRequest.fetchLimit = 1
        // TODO: this should really be done on a background queue
        let card: Card
        if let fetchedCard = try? managedObjectContext.fetch(fetchRequest).first {
            card = fetchedCard
        } else {
            card = NSEntityDescription.insertNewObject(
                forEntityName: CardModel.entityName,
                into: persistentContainer.viewContext) as! Card
        }
        card.configure(from: cardModel, managedObjectContext: managedObjectContext)

        try! persistentContainer.viewContext.save()
    }
}

private extension Card {
    func configure(from cardModel: CardModel, managedObjectContext: NSManagedObjectContext) {
        uuid = cardModel.uuid
        nextDueTime = cardModel.nextDueTime
        numCorrectRepetitions = cardModel.numCorrectRepetitions
        if let deckUUID = cardModel.deckUUID {
            let deckFetchRequest = NSFetchRequest<Deck>(entityName: DeckModel.entityName)
            deckFetchRequest.predicate = NSPredicate(format: "uuid == %@", deckUUID.uuidString)
            deckFetchRequest.fetchLimit = 1
            if let fetchedDeck = try? managedObjectContext.fetch(deckFetchRequest).first {
                deck = fetchedDeck
            }
        }
    }
}
