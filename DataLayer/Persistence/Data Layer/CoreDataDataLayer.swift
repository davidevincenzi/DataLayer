//
//  CoreDataDataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation
import CoreData

class CoreDataDataLayer: NSObject, DataLayer {
    
    // MARK: - Core Data stack
    
    /// Core Data stack container.
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataLayer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    // MARK: - Contexts
    
//    /// The main, read-only context, has the persistent store as parent.
//    /// Automatically merge changes from store.
//    lazy var mainContext: ReadableStorageContext = {
//        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
//
//        // Merge policy is set to prefer store version over in-memory version (since context is read-only).
//        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
//
//        return persistentContainer.viewContext
//    }()
//
//    /// Background context to perform long/write operations.
//    /// Context saves immediatelly propagate changes to the persistent store.
//    lazy var writableContext: StorageContext = {
//        let context = persistentContainer.newBackgroundContext()
//
//        // Merge operations should occur on a property basis (`id` attribute)
//        // and the in memory version “wins” over the persisted one.
//        // All entities have been modeled with an `id` constraint.
//        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//
//        return context
//    }()
    
    /// The main context, has the persistent store as parent.
    lazy var mainContext: StorageContext = {
        let mainManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainManagedObjectContext.name = "MainManagedObjectContext"
        mainManagedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        mainManagedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return mainManagedObjectContext
    }()
    
    /// Unique background context (always a new instance) to perform long/write operations.
    func uniqueBackgroundContext(_ debugName: String) -> StorageContext {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.name = debugName
        context.parent = (mainContext as! NSManagedObjectContext)
        context.undoManager = nil
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    private lazy var backgroundQueue: DispatchQueue = {
        return DispatchQueue(label: "Data Layer Background Queue", qos: .background)
    }()
    
    func performInBackground(_ objects: [Storable?], block: @escaping ([Storable?]) -> (), completion: (() -> Void)?) {
        // get object references (on current thread)
        let refs: [NSManagedObjectID] = objects.compactMap {
            guard let obj = $0 as? NSManagedObject else { return nil }
            return obj.objectID
        }
        
        // create a new background context
        let context = uniqueBackgroundContext("Data Layer Background Context")
        
        // and perform work on a background thread...
        backgroundQueue.async {
            context.performInContext {
                guard let context = context as? NSManagedObjectContext else { return }
                let cdObjects = refs.compactMap { context.object(with: $0) }
                
                // call block with objects valid for this thread
                block(cdObjects as? [Storable] ?? [])
                
                // changes done on this bg context are merged into the main
                // context when we save
                do {
                    try context.save()
                } catch {
                    #warning ("do something to catch the error")
                }
                
                // call completion closure
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    
    // MARK: - Results Controller

    func makeResultsController<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, sectionNameKeyPath: String?, fetchBatchSize: Int?, cacheName: String?) -> ResultsController? {
        return CoreDataResultsController(storing, filtering: filtering, sorting: sorting, context: mainContext, sectionNameKeyPath: sectionNameKeyPath, fetchBatchSize: fetchBatchSize, cacheName: cacheName)
    }
}
