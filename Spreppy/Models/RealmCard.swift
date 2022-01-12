//
//  RealmCard.swift
//  Spreppy
//
//  Created by Russell Blickhan on 1/11/22.
//

import Foundation
import RealmSwift

class RealmCard: Object {
    @Persisted var nextDueTime: Date = Date()
    @Persisted var numCorrectRepetitions: Int = 0
    @Persisted var numIncorrectRepetitions: Int = 0
    @Persisted var frontText: String
    @Persisted var backText: String
    @Persisted(originProperty: "cards") var deck: LinkingObjects<RealmDeck>
    
    convenience init(nextDueTime: Date, numCorrectRepetitions: Int, numIncorrectRepetitions: Int, frontText: String, backText: String) {
        self.init()
        self.nextDueTime = nextDueTime
        self.numCorrectRepetitions = numCorrectRepetitions
        self.numIncorrectRepetitions = numIncorrectRepetitions
        self.frontText = frontText
        self.backText = backText
    }
}
