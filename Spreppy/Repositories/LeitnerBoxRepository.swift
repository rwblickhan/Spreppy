//
//  LeitnerBoxRepository.swift
//  Spreppy
//
//  Created by Russell Blickhan on 12/10/21.
//

import Combine
import CoreData
import Foundation

protocol LeitnerBoxRepository {
    func fetchLeitnerBoxList() -> AnyPublisher<[LeitnerBoxModel], Never>
}

class LeitnerBoxCoreDataRepository: CoreDataRepository<LeitnerBoxModel>, LeitnerBoxRepository,
    NSFetchedResultsControllerDelegate {
    private let fetchedResultsController: NSFetchedResultsController<LeitnerBox>
    private let leitnerBoxListState = CurrentValueSubject<[LeitnerBoxModel], Never>([])

    override init(viewContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        let fetchRequest = LeitnerBox.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)

        super.init(viewContext: viewContext, backgroundContext: backgroundContext)

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            if let leitnerBoxes = fetchedResultsController.fetchedObjects {
                leitnerBoxListState.send(leitnerBoxes.compactMap { LeitnerBoxModel(managedObject: $0) })
            }
        } catch {
            fatalError("###\(#function): Failed to performFetch: \(error)")
        }
    }

    func fetchLeitnerBoxList() -> AnyPublisher<[LeitnerBoxModel], Never> {
        leitnerBoxListState.eraseToAnyPublisher()
    }

    // MARK: NSFetchedResultsControllerDelegate

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let leitnerBoxes = controller.fetchedObjects as? [LeitnerBox] else { return }
        leitnerBoxListState.send(leitnerBoxes.compactMap { LeitnerBoxModel(managedObject: $0) })
    }
}
