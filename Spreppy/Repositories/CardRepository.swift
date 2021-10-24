//
//  CardRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/26/21.
//

import Combine
import CoreData
import Foundation

protocol CardRepository {
    func fetchCard(_ cardID: UUID) -> (CardModel?, AnyPublisher<CardModel, Never>)
    func createOrUpdate(_ cardModel: CardModel)
}

class CardCoreDataRepository: CardRepository {
    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    private typealias Update = (object: Card, type: UpdateType)
    private enum UpdateType {
        case insert, update, delete
    }

    private let state = CurrentValueSubject<[Update], Never>([])

    init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext

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

    func fetchCard(_ cardID: UUID) -> (CardModel?, AnyPublisher<CardModel, Never>) {
        let fetchRequest = NSFetchRequest<Card>(entityName: CardModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", cardID.uuidString)
        fetchRequest.fetchLimit = 1

        let card = (try? viewContext.fetch(fetchRequest))?.first.flatMap { CardModel(managedObject: $0) }
        let updatesPublisher: AnyPublisher<CardModel, Never> = state
            .compactMap { updates -> Update? in
                updates.first(where: { $0.object.uuid == cardID })
            }
            .compactMap { update -> Card? in
                switch update.type {
                case .insert, .update:
                    return update.object
                case .delete:
                    return nil
                }
            }
            .compactMap { CardModel(managedObject: $0) }
            .eraseToAnyPublisher()
        return (card, updatesPublisher)
    }

    func createOrUpdate(_ cardModel: CardModel) {
        let fetchRequest = NSFetchRequest<Card>(entityName: CardModel.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", cardModel.uuid.uuidString)
        fetchRequest.fetchLimit = 1
        let card: Card
        if let fetchedCard = try? backgroundContext.fetch(fetchRequest).first {
            card = fetchedCard
        } else {
            card = NSEntityDescription.insertNewObject(
                forEntityName: CardModel.entityName,
                into: backgroundContext) as! Card
        }
        card.configure(from: cardModel, managedObjectContext: backgroundContext)

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

        let updates: [(Card, UpdateType)] =
            insertedObjects.compactMap { $0 as? Card }.map { ($0, .insert) } +
            updatedObjects.compactMap { $0 as? Card }.map { ($0, .update) } +
            deletedObjects.compactMap { $0 as? Card }.map { ($0, .delete) }

        state.send(updates)
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
