//
//  LeitnerBoxSpacedRepAlgorithm.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/9/21.
//

import Foundation

struct LeitnerBoxSpacedRepAlgorithm {
    private static func newStageDiff(numIncorrectRepetitions: Int32, isCorrect: Bool) -> Int {
        // If the user was correct, bump to the next stage, if there is one
        guard !isCorrect else { return 1 }
        return -Int((Double(numIncorrectRepetitions) / 2).rounded(.up))
    }
}
