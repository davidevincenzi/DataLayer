//
//  CoreDataWithStructsDataLayer.swift
//  DataLayer
//
//  Created by Aleksander Kovacic on 18.10.18.
//

import Foundation
import CoreData

struct EventStruct: EventType {
    var timestamp: Date?
    var event: Event
    
    init(event: Event) {
        timestamp = event.timestamp
        self.event = event
    }
}

struct UserStruct: UserType {
    var name: String?
    var user: User
    
    init(user: User) {
        name = user.name
        self.user = user
    }
}

class CoreDataWithStructsDataLayer: DataLayer {
    
    init() {
        
    }
    
    var moc: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func loadEvents() -> [Event] {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let events: [Event]
        do {
            try events = context.fetch(fetchRequest)
        } catch {
            print("Error: \(error)")
            events = []
        }
        
        return events
    }
    
    func createEvent(creator: String) {
        let context = persistentContainer.viewContext
        
        let user = User(context: context)
        user.name = creator
        
        let newEvent = Event(context: context)
        newEvent.timestamp = Date()
        newEvent.user = user
    }
    
    func deleteEvent(_ event: Event) {
        let context = persistentContainer.viewContext
        context.delete(event)
    }
    
    func updateEvent(_ event: Event, timestamp: Date) {
        event.timestamp = timestamp
    }
    
    func userOfEvent(_ event: Event) -> User? {
        return event.user
    }
    
    func save() {
        saveContext()
    }
    
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
    
}
