//
//  DataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

protocol DataLayer {
    var dataChanged: (() -> Void)? { get set }
    
    func object(at indexPath: IndexPath) -> EventType
    func numberOfEvents() -> Int
    func createEvent()
    func deleteEvent(_ event: EventType)
}

protocol HasDataLayer {
    var dataLayer: DataLayer { get }
}
