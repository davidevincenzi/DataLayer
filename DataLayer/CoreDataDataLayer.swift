//
//  CoreDataDataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation
import CoreData

class CoreDataDataLayer: NSObject, DataLayer {
    
    var dataChanged: (() -> Void)?
    
    private var managedObjectContext: NSManagedObjectContext? = nil
    
    // MARK: - Core Data stack
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataLayer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    override init() {
        super.init()
        self.managedObjectContext = persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetched results controller
    
    private var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "cd_timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil
    
    private func insertNewEvent() -> Event {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
        
        // If appropriate, configure the new managed object.
        newEvent.timestamp = Date()
        
        return newEvent
    }
    
    private func insertNewUser() -> User {
        let context = self.fetchedResultsController.managedObjectContext
        let user = User(context: context)
        
        return user
    }
    
    func object(at indexPath: IndexPath) -> EventType {
        let event = fetchedResultsController.object(at: indexPath)
        return event
    }
    
    func numberOfEvents() -> Int {
        return fetchedResultsController.sections?.first?.numberOfObjects ?? 0
    }
    
    func createEvent() -> EventType {
        return insertNewEvent()
    }
    
    func createUser() -> UserType {
        return insertNewUser()
    }
    
    func deleteEvent(_ event: EventType) {
        guard let event = event as? Event else { fatalError("Event must be a NSManagedObject") }
        
        let context = fetchedResultsController.managedObjectContext
        context.delete(event)
    }
    
    func save() {
        saveContext()
    }
}

extension CoreDataDataLayer: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataChanged?()
    }
}
