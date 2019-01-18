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
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, completion: @escaping (([T]) -> ())) {
        perform { [weak self] in
            guard let bSelf = self else {
                completion([])
                return
            }
            let objects = bSelf.fetch(storing, filtering: filtering, sorting: sorting)
            completion(objects)
        }
    }
    
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?) -> [T] {
        let entityName = storing.entityName
        
        // build fetch request
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        
        // filtering
        fetchRequest.predicate = filtering?.filter()
        
        // sorting
        if let sort = sorting?.sortDescriptor() {
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
    func create<T>(_ storing: Storing<T>, completion: @escaping ((T) -> Void)) throws {
        
        let entityName = storing.entityName
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: self) else {
            throw DataLayerError.persistence("Unable to get entity description for \(entityName)")
        }
        
        perform {
            let newObject = NSManagedObject(entity: entityDescription, insertInto: self) as! T
            completion(newObject)
        }
    }
    
    func saveContext() throws {
        performAndWait {
            if hasChanges {
                try? save()
            }
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
        let objectId = managedObject.objectID
        performAndWait {
            let obj = self.object(with: objectId)
            delete(obj)
        }
    }
    
    func deleteAll<T>(_ storing: Storing<T>) throws {
        let entityName = storing.entityName
        
        performAndWait { [weak self] in
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
