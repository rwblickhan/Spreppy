//
//  Repositories.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/28/21.
//

import Foundation

protocol Repositories {
    var cardRepo: CardRepository { get }
    var deckRepo: DeckRepository { get }
    var leitnerBoxRepo: LeitnerBoxRepository { get }
}
