//
//  Repositories.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/28/21.
//

import CoreData
import Foundation

protocol Repositories {
    var cardRepo: CardRepository { get }
    var deckRepo: DeckRepository { get }
}

class CoreDataRepositories: Repositories {
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
