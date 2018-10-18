//
//  CoreDataWithStructsDataLayer.swift
//  DataLayer
//
//  Created by Aleksander Kovacic on 18.10.18.
//

import Foundation
import CoreData

class CoreDataWithStructsDataLayer: DataLayer {
  
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
    
    var dataChanged: (() -> Void)?
    
    private var allEvents: [EventStruct]
    
    init() {
        allEvents = []
        loadEvents()
        
        let context = persistentContainer.viewContext
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewContextSaved),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: context)
    }
    
    private func loadEvents() {
        let context = persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let events: [Event]
        do {
            try events = context.fetch(fetchRequest)
        } catch {
            print("Error: \(error)")
            return
        }
        
        // Instead of overwriting allEvents we could calculate the diff here
        // and notify which events exactly were created/deleted/updated
        // so we can make use of partial table reload (and cell animations)
        allEvents = events.map({ EventStruct(event: $0) })
        
        dataChanged?()
    }
    
    func numberOfEvents() -> Int {
        return allEvents.count
    }
    
    func object(at indexPath: IndexPath) -> EventType {
        return allEvents[indexPath.row]
    }
    
    func createEvent(creator: String) {
        let context = persistentContainer.viewContext
        
        let user = User(context: context)
        user.name = creator
        
        let newEvent = Event(context: context)
        newEvent.timestamp = Date()
        newEvent.user = user
    }
    
    func deleteEvent(_ event: EventType) {
        guard let eventStruct = event as? EventStruct else { fatalError("Event must be an EventStruct") }
        
        let context = persistentContainer.viewContext
        context.delete(eventStruct.event)
    }
    
    func userOfEvent(_ event: EventType) -> UserType? {
        guard let eventStruct = event as? EventStruct else { fatalError("Event must be an EventStruct") }
        guard let user = eventStruct.event.user else { return nil }
        
        let userStruct = UserStruct(user: user)
        return userStruct
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
    
    @objc private func viewContextSaved() {
        loadEvents()
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
    

}
