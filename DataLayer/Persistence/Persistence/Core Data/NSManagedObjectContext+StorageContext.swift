//
//  NSManagedObjectContext+StorageContext.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//

import Foundation
import CoreData

extension NSManagedObjectContext: ReadableStorageContext {
    
    func loadObject<T>(withId id: AnyObject) -> T? where T : Storable {
        guard let objectID = id as? NSManagedObjectID else {
            print("`id` is not an `NSManagedObjectID`.")
            return nil
        }
        
        return object(with: objectID) as? T
    }
    
    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([T]) -> ())) where T : Storable {
        guard
            let MO = model as? NSManagedObject.Type,
            let entityName = MO.entity().name else {
                print("`model` is not of `NSManagedObject` type.")
                return
        }
        
        perform {
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
            
            completion(objects)
        }
    }
    
}

extension NSManagedObjectContext: WritableStorageContext {
    
    func create<T>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws where T : Storable {
        guard let MO = model as? NSManagedObject.Type else {
            throw DataLayerError.persistence("`model` is not of type `NSManagedObject` type.")
        }
        
        perform {
            let newObject = MO.init(context: self) as! T
            completion(newObject)
        }
    }
    
    func save(object: Storable) throws {
        if hasChanges {
            try save()
        }
    }
    
    func update(block: @escaping () -> ()) throws {
        perform {
            block()
        }
    }
    
    func delete(object: Storable) throws {
        guard let managedObject = object as? NSManagedObject else {
            throw DataLayerError.persistence("`object` is not an `NSManagedObject`.")
        }
        delete(managedObject)
    }
    
    func deleteAll<T>(_ model: T.Type) throws where T : Storable {
        guard
            let MO = model as? NSManagedObject.Type,
            let entityName = MO.entity().name else {
                throw DataLayerError.persistence("`model` is not of type `NSManagedObject` type.")
        }
        
        perform { [weak self] in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try self?.execute(deleteRequest)
            } catch {
                print("Failed to delete all objects of type `\(model)` with error: \(error)")
            }
        }
    }
    
}
