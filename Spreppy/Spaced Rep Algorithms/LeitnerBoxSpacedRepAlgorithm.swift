//
//  LeitnerBoxSpacedRepAlgorithm.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/9/21.
//

import Foundation

struct LeitnerBoxSpacedRepAlgorithm {
    static func newStage(numIncorrectRepetitions: Int32, isCorrect: Bool, stages: [LeitnerBoxModel], currentStage: LeitnerBoxModel) -> LeitnerBoxModel {
        var stagesMap = [UUID: LeitnerBoxModel]()
        for stage in stages {
            stagesMap[stage.uuid] = stage
        }
        
        
        let newStageDiff = newStageDiff(numIncorrectRepetitions: numIncorrectRepetitions, isCorrect: isCorrect)
        if newStageDiff > 0 {
            var stage = currentStage
            for _ in 0 ..< newStageDiff {
                if
                    let nextStageUUID = stage.nextStageUUID,
                    let nextStage = stagesMap[nextStageUUID]
                {
                    stage = nextStage
                }
            }
            return stage
        } else if newStageDiff < 0 {
            var stage = currentStage
            for _ in 0 ..< -newStageDiff {
                if
                    let previousStageUUID = stage.previousStageUUID,
                    let previousStage = stagesMap[previousStageUUID]
                {
                    stage = previousStage
                }
            }
            return stage
        } else {
            return currentStage
        }
    }
    
    private static func newStageDiff(numIncorrectRepetitions: Int32, isCorrect: Bool) -> Int {
        // If the user was correct, bump to the next stage, if there is one
        guard !isCorrect else { return 1 }
        return -Int((Double(numIncorrectRepetitions) / 2).rounded(.up))
    }
}
