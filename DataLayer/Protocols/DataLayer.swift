//
//  DataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

protocol DataLayer {
    var dataChanged: (() -> Void)? { get set }
    
    func numberOfEvents() -> Int
    func object(at indexPath: IndexPath) -> EventType
    func createEvent(creator: String)
    func deleteEvent(_ event: EventType)
    func userOfEvent(_ event: EventType) -> UserType?
    func save()
}

protocol HasDataLayer {
    var dataLayer: DataLayer { get }
}
