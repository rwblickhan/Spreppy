//
//  Model.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import CoreData
import Foundation

protocol Model {
    associatedtype AssociatedObjectType: ModelObject
    static var entityName: String { get }
    var uuid: UUID { get }
    init?(managedObject: AssociatedObjectType)
}

protocol ModelObject: NSManagedObject {
    associatedtype AssociatedModel: Model
    var uuid: UUID? { get }
    func configure(from model: AssociatedModel, managedObjectContext: NSManagedObjectContext)
}
