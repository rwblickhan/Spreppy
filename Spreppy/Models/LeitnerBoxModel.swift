//
//  LeitnerBoxModel.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/9/21.
//

import CoreData
import Foundation

struct LeitnerBoxModel: Model, Hashable {
    typealias AssociatedObjectType = LeitnerBox
    static let entityName: String = "LeitnerBox"

    let uuid: UUID
    let title: String
    let delayBeforeDisplay: Double
    let previousStageUUID: UUID?
    let nextStageUUID: UUID?

    init?(managedObject: LeitnerBox) {
        guard
            let uuid = managedObject.uuid,
            let title = managedObject.title
        else { return nil }
        self.uuid = uuid
        self.title = title
        self.delayBeforeDisplay = managedObject.delayBeforeDisplay
        self.previousStageUUID = managedObject.previousStage?.uuid
        self.nextStageUUID = managedObject.nextStage?.uuid
    }

    init(uuid: UUID = UUID(), title: String = "", delayBeforeDisplay: Double = 0.0, previousStageUUID: UUID? = nil, nextStageUUID: UUID? = nil) {
        self.uuid = uuid
        self.title = title
        self.delayBeforeDisplay = delayBeforeDisplay
        self.previousStageUUID = nil
        self.nextStageUUID = nil
    }
}
