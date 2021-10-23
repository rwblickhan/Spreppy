//
//  DeckRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Combine
import CoreData
import Foundation

protocol DeckRepository {
    func fetchDeckList() -> AnyPublisher<[DeckModel], Never>
    func createOrUpdate(_ deckModel: DeckModel)
    func delete(_ deckModel: DeckModel)
}

class DeckCoreDataRepository: NSObject, DeckRepository, NSFetchedResultsControllerDelegate {
    private let persistentContainer: NSPersistentContainer
    private let deckListState = CurrentValueSubject<[DeckModel], Never>([])
    private let fetchedResultsController: NSFetchedResultsController<Deck>

    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        let fetchRequest = Deck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            if let decks = fetchedResultsController.fetchedObjects {
                deckListState.send(decks.compactMap { DeckModel(managedObject: $0) })
            }
        } catch {
            fatalError("###\(#function): Failed to performFetch: \(error)")
        }
    }

    func fetchDeckList() -> AnyPublisher<[DeckModel], Never> {
        deckListState.eraseToAnyPublisher()
    }

    func createOrUpdate(_ deckModel: DeckModel) {
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Deck>(entityName: DeckModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", deckModel.uuid.uuidString)
        fetchRequest.fetchLimit = 1
        // TODO: https://github.com/rwblickhan/Spreppy/issues/19
        // This should really be done on a background queue
        let deck: Deck
        if let fetchedDeck = try? managedObjectContext.fetch(fetchRequest).first {
            deck = fetchedDeck
        } else {
            deck = NSEntityDescription.insertNewObject(
                forEntityName: DeckModel.entityName,
                into: persistentContainer.viewContext) as! Deck
        }

        deck.configure(from: deckModel, managedObjectContext: managedObjectContext)

        try! persistentContainer.viewContext.save()
    }
    
    func delete(_ deckModel: DeckModel) {
        let fetchRequest = NSFetchRequest<Deck>(entityName: DeckModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", deckModel.uuid.uuidString)
        fetchRequest.fetchLimit = 1

        guard let deck = (try? persistentContainer.viewContext.fetch(fetchRequest))?.first else { assert(false)
        }
        persistentContainer.viewContext.delete(deck)
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let decks = controller.fetchedObjects as? [Deck] else { return }
        deckListState.send(decks.compactMap { DeckModel(managedObject: $0) })
    }
}

private extension Deck {
    func configure(from deckModel: DeckModel, managedObjectContext: NSManagedObjectContext) {
        uuid = deckModel.uuid
        title = deckModel.title
        summary = deckModel.summary
        rank = deckModel.rank
        let cardFetchRequest = NSFetchRequest<Card>(entityName: CardModel.entityName)
        cardFetchRequest.predicate = NSPredicate(format: "uuid IN $CARD_LIST")
            .withSubstitutionVariables(["CARD_LIST": deckModel.cardUUIDs.map(\.uuidString)])
        if let fetchedCards = try? managedObjectContext.fetch(cardFetchRequest) {
            cards = NSSet(array: fetchedCards)
        }
    }
}

