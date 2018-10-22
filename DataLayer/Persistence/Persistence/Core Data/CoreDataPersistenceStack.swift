//
//  CoreDataPersistenceStack.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation
import CoreData

class CoreDataPersistenceStack: PersistenceStack {
    
    // Core Data stack container.
    let container: NSPersistentContainer
    
    
    // MARK: - Setup
    
    /// Initialize the data controller.
    ///
    /// - Parameter modelName: The Core Data model name.
    init(modelName: String = "DataLayer", managedObjectModel model: NSManagedObjectModel? = nil) {
        if let model = model {
            container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        }
        else {
            container = NSPersistentContainer(name: modelName)
        }
        setupContainer()
    }
    
    /// Performs any additional container configuration.
    ///
    /// Base implementation does nothing. Useful for unit testing.
    func setupContainer() {
        // accept base configuration by default
        containerWasSetup = true
    }
    
    /// Was c=persistent container already setup?
    var containerWasSetup: Bool = false
    
    /// Load the persistent store.
    func load(completion: ((Error?) -> Void)? = nil) {
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Failed to load Core Data stack: \(error), \(error.userInfo)")
            }
            completion?(error)
        })
    }
    
    
    // MARK: - Contexts
    
    /// The main, read-only context, has the persistent store as parent.
    /// Automatically merge changes from store.
    lazy var readableContext: ReadableStorageContext = {
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Merge policy is set to prefer store version over in-memory version (since context is read-only).
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        
        return container.viewContext
    }()
    
    /// Background context to perform long/write operations.
    /// Context saves immediatelly propagate changes to the persistent store.
    lazy var writableContext: WritableStorageContext = {
        let context = container.newBackgroundContext()
        
        // Merge operations should occur on a property basis (`id` attribute)
        // and the in memory version “wins” over the persisted one.
        // All entities have been modeled with an `id` constraint.
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        return context
    }()
}
