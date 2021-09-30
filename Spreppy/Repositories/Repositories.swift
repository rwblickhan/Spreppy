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

    init(persistentContainer: NSPersistentContainer) {
        cardRepo = CardCoreDataRepository(persistentContainer: persistentContainer)
        deckRepo = DeckCoreDataRepository(persistentContainer: persistentContainer)
    }
}
