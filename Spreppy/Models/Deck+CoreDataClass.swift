//
//  Deck+CoreDataClass.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/24/21.
//
//

import CoreData
import Foundation

@objc(Deck)
public class Deck: NSManagedObject, ModelObject {
    typealias AssociatedModel = DeckModel

    func configure(from model: DeckModel, managedObjectContext: NSManagedObjectContext) {
        uuid = model.uuid
        title = model.title
        summary = model.summary
        rank = model.rank
        let cardFetchRequest = NSFetchRequest<Card>(entityName: CardModel.entityName)
        cardFetchRequest.predicate = NSPredicate(format: "uuid IN $CARD_LIST")
            .withSubstitutionVariables(["CARD_LIST": model.cardUUIDs.map(\.uuidString)])
        if let fetchedCards = try? managedObjectContext.fetch(cardFetchRequest) {
            cards = NSSet(array: fetchedCards)
        }
    }
}
