//
//  LeitnerBox+CoreDataClass.swift
//  Spreppy
//
//  Created by Russell Blickhan on 11/9/21.
//
//

import CoreData
import Foundation

@objc(LeitnerBox)
public class LeitnerBox: NSManagedObject, ModelObject {
    typealias AssociatedModel = LeitnerBoxModel

    func configure(from model: LeitnerBoxModel, managedObjectContext: NSManagedObjectContext) {
        uuid = model.uuid
        title = model.title
        delayBeforeDisplay = model.delayBeforeDisplay

        if let previousStageUUID = previousStage?.uuid {
            let previousStageRequest = NSFetchRequest<LeitnerBox>(entityName: LeitnerBoxModel.entityName)
            previousStageRequest.predicate = NSPredicate(format: "uuid == %@", previousStageUUID.uuidString)
            previousStageRequest.fetchLimit = 1
            if let fetchedPreviousStage = try? managedObjectContext.fetch(previousStageRequest).first {
                previousStage = fetchedPreviousStage
            }
        } else {
            previousStage = nil
        }
        if let nextStageUUID = nextStage?.uuid {
            let nextStageRequest = NSFetchRequest<LeitnerBox>(entityName: LeitnerBoxModel.entityName)
            nextStageRequest.predicate = NSPredicate(format: "uuid == %@", nextStageUUID.uuidString)
            nextStageRequest.fetchLimit = 1
            if let fetchedNextStage = try? managedObjectContext.fetch(nextStageRequest).first {
                nextStage = fetchedNextStage
            }
        } else {
            nextStage = nil
        }
    }
}
