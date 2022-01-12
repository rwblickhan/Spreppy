//
//  Repositories.swift
//  Spreppy
//
//  Created by Russell Blickhan on 9/28/21.
//

import Foundation
import RealmSwift

class Repository<ModelObject: Object> {
    private let realm: Realm
    
    init() {
        realm = try! Realm()
    }
    
    func fetch() -> Results<ModelObject> {
        realm.objects(ModelObject.self)
    }
    
    func create(_ modelObject: ModelObject) throws {
        try realm.write {
            realm.add(modelObject)
        }
    }
    
    func update(block: () -> Void) throws {
        try realm.write(block)
    }
    
    func delete(_ modelObject: ModelObject) throws {
        try realm.write {
            realm.delete(modelObject)
        }
    }
}
