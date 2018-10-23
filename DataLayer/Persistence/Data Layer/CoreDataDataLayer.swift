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
    
    /// The main, read-only context, has the persistent store as parent.
    /// Automatically merge changes from store.
    lazy var mainContext: ReadableStorageContext = {
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        // Merge policy is set to prefer store version over in-memory version (since context is read-only).
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        return persistentContainer.viewContext
    }()
    
    /// Background context to perform long/write operations.
    /// Context saves immediatelly propagate changes to the persistent store.
    lazy var writableContext: StorageContext = {
        let context = persistentContainer.newBackgroundContext()

        // Merge operations should occur on a property basis (`id` attribute)
        // and the in memory version “wins” over the persisted one.
        // All entities have been modeled with an `id` constraint.
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        return context
    }()
    
    
    // MARK: - Results Controller
    
    func makeResultsController(_ entityType: Storable.Type, predicate: NSPredicate?, sorted: Sorted?) -> ResultsController? {
        return CoreDataResultsController(entityType.entityName, context: mainContext, predicate: predicate, sorted: sorted)
    }
}
