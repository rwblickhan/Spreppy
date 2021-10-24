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
    func fetch(_ deckID: UUID) -> (DeckModel?, AnyPublisher<DeckModel, Never>)
    func createOrUpdate(_ deckModel: DeckModel)
    func delete(_ deckModel: DeckModel)
}

class DeckCoreDataRepository: CoreDataRepository<DeckModel>, DeckRepository, NSFetchedResultsControllerDelegate {
    private let fetchedResultsController: NSFetchedResultsController<Deck>
    private let deckListState = CurrentValueSubject<[DeckModel], Never>([])
    
    override init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        let fetchRequest = Deck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "rank", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        super.init(viewContext: viewContext, backgroundContext: backgroundContext)
        
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

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let decks = controller.fetchedObjects as? [Deck] else { return }
        deckListState.send(decks.compactMap { DeckModel(managedObject: $0) })
    }
}
