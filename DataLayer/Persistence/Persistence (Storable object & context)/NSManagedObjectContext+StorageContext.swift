//
//  NSManagedObjectContext+StorageContext.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//

import Foundation
import CoreData

extension NSManagedObjectContext: ReadableStorageContext {
    
    func loadObject(withId id: AnyObject, completion: @escaping ((Storable?) -> ())) {
        guard let objectID = id as? NSManagedObjectID else {
            print("`id` is not an `NSManagedObjectID`.")
            completion(nil)
            return
        }
        perform { [weak self] in
            completion(self?.object(with: objectID) as? Storable)
        }
    }
    
    func loadObject(withId id: AnyObject) -> Storable? {
        guard let objectID = id as? NSManagedObjectID else {
            return nil
        }
        
        return object(with: objectID) as? Storable
    }
    
    func fetch<T>(_ entity: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([T]) -> ())) {
        perform { [weak self] in
            guard let bSelf = self else {
                completion([])
                return
            }
            let objects = bSelf.fetch(entity, predicate: predicate, sorted: sorted)
            completion(objects)
        }
    }
    
    func fetch<T>(_ entity: T.Type, predicate: NSPredicate?, sorted: Sorted?) -> [T] {
        guard let entityName = NSManagedObjectContext.entityName(for: entity) else { return [T]() }
        
        // build fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        // sorting
        if let sort = sorted {
            let sortDescriptor = NSSortDescriptor(key: sort.key, ascending: sort.ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        // fetch
        var objects: [T] = []
        do {
            if let fetched = try self.fetch(fetchRequest) as? [T] {
                objects = fetched
            }
        } catch {
            print("Failed to retrieve objects with error: \(error)")
        }
        
        return objects
    }
}

extension NSManagedObjectContext: WritableStorageContext {
    
    func create<T>(_ entity: T.Type, completion: @escaping ((T) -> Void)) throws {
        guard
            let entityName = NSManagedObjectContext.entityName(for: entity),
            let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self) else {
            throw DataLayerError.persistence("Unable to get entity description for \(entity)")
        }
        
        perform {
            let newObject = NSManagedObject(entity: entityDescription, insertInto: self) as! T
            completion(newObject)
        }
    }
    
    func saveContext() throws {
        if hasChanges {
            try save()
        }
    }
    
    func update(block: @escaping () -> ()) throws {
        perform {
            block()
        }
    }
    
    func delete(_ object: Storable) throws {
        guard let managedObject = object as? NSManagedObject else {
            throw DataLayerError.persistence("`object` is not an `NSManagedObject`.")
        }
        guard managedObject.managedObjectContext == self else {
            throw DataLayerError.persistence("Trying to delete an object from the wrong context.")
        }
        delete(managedObject)
    }
    
    func deleteAll(_ entityName: String) throws {
        perform { [weak self] in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self?.execute(deleteRequest)
            } catch {
                print("Failed to delete all objects of entity name `\(entityName)` with error: \(error)")
            }
        }
    }
    
}

extension NSManagedObjectContext {
    static func entityName<T>(for storableEntity: T.Type) -> String? {
        switch storableEntity {
        case is EventType.Protocol:
            return "Event"
        case is UserType.Protocol:
            return "User"
        default:
            return nil
        }
    }
    
    static func entityType<T>(for storableEntity: T.Type) -> NSManagedObject.Type? {
        switch storableEntity {
        case is EventType.Protocol:
            return Event.self
        case is UserType.Protocol:
            return User.self
        default:
            return nil
        }
    }
}
