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
    
    func fetch<T>(_ entityName: String, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([T]) -> ())) where T : Storable {
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
    
    func create(_ entity: Storable.Type, completion: @escaping ((Storable) -> Void)) throws {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entity.entityName, in: self) else {
            throw DataLayerError.persistence("Unable to get entity description for \(entity.entityName)")
        }
        
        perform {
            //let newObject = MO.init(context: self) as! T
            guard let newObject = NSManagedObject(entity: entityDescription, insertInto: self) as? Storable else {
                fatalError("The entity must conform to the Storable type")
            }
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
