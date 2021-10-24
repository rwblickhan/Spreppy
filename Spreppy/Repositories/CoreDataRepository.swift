//
//  CoreDataRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 10/24/21.
//

import Combine
import CoreData
import Foundation

struct CoreDataRepositories: Repositories {
    let cardRepo: CardRepository
    let deckRepo: DeckRepository

    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    init(persistentContainer: NSPersistentContainer) {
        viewContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()

        cardRepo = CardCoreDataRepository(viewContext: viewContext, backgroundContext: backgroundContext)
        deckRepo = DeckCoreDataRepository(viewContext: viewContext, backgroundContext: backgroundContext)
    }
}

class CoreDataRepository<ModelType: Model>: NSObject {
    private enum UpdateType {
        case insert, update, delete
    }

    private typealias Update = (object: ModelType.AssociatedObjectType, type: UpdateType)

    private let viewContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    private let state = CurrentValueSubject<[Update], Never>([])

    init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.backgroundContext = backgroundContext
        super.init()

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

    func fetch(_ uuid: UUID) -> (ModelType?, AnyPublisher<ModelType, Never>) {
        let fetchRequest = NSFetchRequest<ModelType.AssociatedObjectType>(entityName: ModelType.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid.uuidString)
        fetchRequest.fetchLimit = 1

        let model = (try? viewContext.fetch(fetchRequest))?.first.flatMap { ModelType(managedObject: $0) }
        let updatesPublisher: AnyPublisher<ModelType, Never> = state
            .compactMap { updates -> Update? in
                updates.first(where: { $0.object.uuid == uuid })
            }
            .compactMap { update -> ModelType.AssociatedObjectType? in
                switch update.type {
                case .insert, .update:
                    return update.object
                case .delete:
                    return nil
                }
            }
            .compactMap { ModelType(managedObject: $0) }
            .eraseToAnyPublisher()
        return (model, updatesPublisher)
    }

    func createOrUpdate(_ model: ModelType) {
        let fetchRequest = NSFetchRequest<ModelType.AssociatedObjectType>(entityName: ModelType.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", model.uuid.uuidString)
        fetchRequest.fetchLimit = 1
        let object: ModelType.AssociatedObjectType
        if let fetchedObject = try? backgroundContext.fetch(fetchRequest).first {
            object = fetchedObject
        } else {
            object = NSEntityDescription.insertNewObject(
                forEntityName: ModelType.entityName,
                into: backgroundContext) as! ModelType.AssociatedObjectType
        }

        if let model = model as? ModelType.AssociatedObjectType.AssociatedModel {
            object.configure(from: model, managedObjectContext: backgroundContext)
        } else {
            assert(false, "AssociatedObjectType and AssociatedModel should be identical")
        }

        try! backgroundContext.save()
    }

    func delete(_ model: ModelType) {
        let fetchRequest = NSFetchRequest<Deck>(entityName: ModelType.entityName)
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", model.uuid.uuidString)
        fetchRequest.fetchLimit = 1

        guard let object = (try? viewContext.fetch(fetchRequest))?.first else { assert(false); return }
        viewContext.delete(object)
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

        let insertedObjectsWithType: [(ModelType.AssociatedObjectType, UpdateType)] = insertedObjects
            .compactMap { $0 as? ModelType.AssociatedObjectType }.map { ($0, .insert) }
        let updatedObjectsWithType: [(ModelType.AssociatedObjectType, UpdateType)] = updatedObjects
            .compactMap { $0 as? ModelType.AssociatedObjectType }.map { ($0, .update) }
        let deletedObjectsWithType: [(ModelType.AssociatedObjectType, UpdateType)] = deletedObjects
            .compactMap { $0 as? ModelType.AssociatedObjectType }.map { ($0, .delete) }
        let updates = insertedObjectsWithType + updatedObjectsWithType + deletedObjectsWithType

        state.send(updates)
    }
}
