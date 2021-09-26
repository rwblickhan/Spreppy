//
//  Model.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import Foundation
import CoreData

protocol Model {
    associatedtype ModelType: NSManagedObject
    static var entityName: String { get }
    init?(managedObject: ModelType)
}
