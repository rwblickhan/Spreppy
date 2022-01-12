//
//  RealmDeck.swift
//  Spreppy
//
//  Created by Russell Blickhan on 1/11/22.
//

import Foundation
import RealmSwift

class RealmDeck: Object {
    @Persisted(primaryKey: true) var id: UUID
    @Persisted var title: String = ""
    @Persisted var summary: String?
    @Persisted var rank: Int
    @Persisted var cards: List<RealmCard>

    convenience init(id: UUID = UUID(), title: String, summary: String?, rank: Int, cards: List<RealmCard>) {
        self.init()
        self.id = id
        self.title = title
        self.summary = summary
        self.rank = rank
        self.cards = cards
    }
}
