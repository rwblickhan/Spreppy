//
//  Model.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/25/21.
//

import CoreData
import Foundation

protocol Model {
    associatedtype ModelType: NSManagedObject
    static var entityName: String { get }
    init?(managedObject: ModelType)
}
