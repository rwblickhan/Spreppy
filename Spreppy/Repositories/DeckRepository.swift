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
    func fetchDeck(_ deckID: UUID) -> (DeckModel?, AnyPublisher<DeckModel, Never>)
    func createOrUpdate(_ deckModel: DeckModel)
}

class DeckCoreDataRepository: NSObject, DeckRepository, NSFetchedResultsControllerDelegate {
    private let deckListState = CurrentValueSubject<[DeckModel], Never>([])
    private let fetchedResultsController: NSFetchedResultsController<Deck>

    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    private typealias Update = (object: Deck, type: UpdateType)
    private enum UpdateType {
        case insert, update, delete
    }

    private let state = CurrentValueSubject<[Update], Never>([])

    init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext

        let fetchRequest = Deck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
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

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(viewContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: viewContext)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(backgroundContextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: backgroundContext)
    }

    func fetchDeckList() -> AnyPublisher<[DeckModel], Never> {
        deckListState.eraseToAnyPublisher()
    }

    func fetchDeck(_ deckID: UUID) -> (DeckModel?, AnyPublisher<DeckModel, Never>) {
        let fetchRequest = NSFetchRequest<Deck>(entityName: DeckModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", deckID.uuidString)
        fetchRequest.fetchLimit = 1

        let deck = (try? viewContext.fetch(fetchRequest))?.first.flatMap { DeckModel(managedObject: $0) }
        let updatesPublisher: AnyPublisher<DeckModel, Never> = state
            .compactMap { updates -> Update? in
                updates.first(where: { $0.object.uuid == deckID })
            }
            .compactMap { update -> Deck? in
                switch update.type {
                case .insert, .update:
                    return update.object
                case .delete:
                    return nil
                }
            }
            .compactMap { DeckModel(managedObject: $0) }
            .eraseToAnyPublisher()
        return (deck, updatesPublisher)
    }

    func createOrUpdate(_ deckModel: DeckModel) {
        let fetchRequest = NSFetchRequest<Deck>(entityName: DeckModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", deckModel.uuid.uuidString)
        fetchRequest.fetchLimit = 1
        let deck: Deck
        if let fetchedDeck = try? backgroundContext.fetch(fetchRequest).first {
            deck = fetchedDeck
        } else {
            deck = NSEntityDescription.insertNewObject(
                forEntityName: DeckModel.entityName,
                into: backgroundContext) as! Deck
        }

        deck.configure(from: deckModel, managedObjectContext: backgroundContext)

        try! backgroundContext.save()
    }

    @objc private func viewContextDidSave(_ notification: Notification) {
        guard
            let context = notification.object as? NSManagedObjectContext,
            context === viewContext
        else { return }

        processUpdatesInViewContext(notification)
        backgroundContext.perform {
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
        }
    }

    @objc private func backgroundContextDidSave(_ notification: Notification) {
        guard
            let context = notification.object as? NSManagedObjectContext,
            context === backgroundContext
        else { return }

        viewContext.perform {
            self.viewContext.mergeChanges(fromContextDidSave: notification)
            self.processUpdatesInViewContext(notification)
        }
    }

    private func processUpdatesInViewContext(_ notification: Notification) {
        let insertedObjects = notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []
        let updatedObjects = notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []
        let deletedObjects = notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []

        let updates: [(Deck, UpdateType)] =
            insertedObjects.compactMap { $0 as? Deck }.map { ($0, .insert) } +
            updatedObjects.compactMap { $0 as? Deck }.map { ($0, .update) } +
            deletedObjects.compactMap { $0 as? Deck }.map { ($0, .delete) }

        state.send(updates)
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
