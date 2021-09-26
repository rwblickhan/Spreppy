//
//  DeckRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Foundation
import Combine
import CoreData

protocol DeckRepository {
    func fetchDeckList() -> AnyPublisher<Array<DeckModel>, Never>
    func create(_ deckModel: DeckModel)
}

class DeckCoreDateRepository: NSObject, DeckRepository, NSFetchedResultsControllerDelegate {
    private let persistentContainer: NSPersistentContainer
    private let deckListState = CurrentValueSubject<Array<DeckModel>, Never>([])
    private let fetchedResultsController: NSFetchedResultsController<Deck>
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        let fetchRequest = Deck.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        super.init()
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("###\(#function): Failed to performFetch: \(error)")
        }
    }
    
    func fetchDeckList() -> AnyPublisher<Array<DeckModel>, Never> {
        return deckListState.eraseToAnyPublisher()
    }
    
    func create(_ deckModel: DeckModel) {
        // TODO this should really be done on a background queue
        let deck = NSEntityDescription.insertNewObject(forEntityName: DeckModel.entityName, into: persistentContainer.viewContext) as! Deck
        deck.configure(from: deckModel)
        try! persistentContainer.viewContext.save()
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let decks = controller.fetchedObjects as? [Deck] else { return }
        deckListState.send(decks.compactMap { DeckModel(managedObject: $0) })
    }
}
