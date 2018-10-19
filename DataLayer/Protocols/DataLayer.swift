//
//  DataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation
import CoreData

protocol DataLayer {
    var moc: NSManagedObjectContext { get }
    func loadEvents() -> [Event]
    func createEvent(creator: String)
    func deleteEvent(_ event: Event)
    func updateEvent(_ event: Event, timestamp: Date)
    func userOfEvent(_ event: Event) -> User?
    func save()
}
