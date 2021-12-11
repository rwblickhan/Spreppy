//
//  LeitnerBoxSpacedRepAlgorithmTests.swift
//  SpreppyTests
//
//  Created by Russell Blickhan on 12/10/21.
//

import Foundation
@testable import Spreppy
import XCTest

class LeitnerBoxSpacedRepAlgorithmTests: XCTestCase {
    func testIsCorrect() {
        let previousStage = LeitnerBoxModel()
        let nextStage = LeitnerBoxModel()
        let currentStage = LeitnerBoxModel(previousStageUUID: previousStage.uuid, nextStageUUID: nextStage.uuid)

        let newStage = LeitnerBoxSpacedRepAlgorithm.newStage(
            numIncorrectRepetitions: 10,
            isCorrect: true,
            stages: [previousStage, currentStage, nextStage],
            currentStage: currentStage)
        XCTAssertEqual(nextStage, newStage)
    }

    func testNoDiff() {
        let previousStage = LeitnerBoxModel()
        let nextStage = LeitnerBoxModel()
        let currentStage = LeitnerBoxModel(previousStageUUID: previousStage.uuid, nextStageUUID: nextStage.uuid)

        let newStage = LeitnerBoxSpacedRepAlgorithm.newStage(
            numIncorrectRepetitions: 0,
            isCorrect: false,
            stages: [previousStage, nextStage, currentStage],
            currentStage: currentStage)
        XCTAssertEqual(newStage, currentStage)
    }

    func testOneIncorrect() {
        let previousStage = LeitnerBoxModel()
        let nextStage = LeitnerBoxModel()
        let currentStage = LeitnerBoxModel(previousStageUUID: previousStage.uuid, nextStageUUID: nextStage.uuid)

        let newStage = LeitnerBoxSpacedRepAlgorithm.newStage(
            numIncorrectRepetitions: 1,
            isCorrect: false,
            stages: [previousStage, nextStage, currentStage],
            currentStage: currentStage)
        XCTAssertEqual(newStage, previousStage)
    }

    func testMultipleIncorrect() {
        let previousPreviousStage = LeitnerBoxModel()
        let previousStage = LeitnerBoxModel(previousStageUUID: previousPreviousStage.uuid)
        let currentStage = LeitnerBoxModel(previousStageUUID: previousStage.uuid)

        let newStage = LeitnerBoxSpacedRepAlgorithm.newStage(
            numIncorrectRepetitions: 4,
            isCorrect: false,
            stages: [previousPreviousStage, previousStage, currentStage],
            currentStage: currentStage)
        XCTAssertEqual(newStage, previousPreviousStage)
    }
}
