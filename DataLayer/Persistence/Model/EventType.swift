//
//  EventType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

// MARK: - EventType Protocol

protocol EventType: Storable {
    var id: String? { get set }
    var remoteId: String? { get set }
    var timestamp: Date? { get set }
    
    var user: UserType? { get set }
}

extension EventType {
    
    var remoteId: String? {
        get {
            return object(forProperty: Property.Event.remoteID)
        }
        set {
            setObject(newValue, forProperty: Property.Event.remoteID)
        }
    }
    
    var timestamp: Date? {
        get {
            return object(forProperty: Property.Event.timestamp)
        }
        set {
            setObject(newValue, forProperty: Property.Event.timestamp)
        }
    }
    
    var user: UserType? {
        get {
            return object(forProperty: Property.Event.user)
        }
        set {
            setObject(newValue, forProperty: Property.Event.user)
        }
    }
}

// MARK: - Storing

extension Storing where T == EventType {
    static var event: Storing<EventType> {
        return Storing<EventType>(entityName: EntityName.event, updateableProperties: [
            Property.Event.id,
            Property.Event.remoteID,
            Property.Event.timestamp,
            Property.Event.user,
            ])
    }
}

// MARK: - Filtering

extension Filtering where T == EventType {
    
    static func timestamp(largerThan date: Date) -> Filtering<EventType> {
        return Filtering<EventType> {
            return NSPredicate(format: "%K > %@", Property.Event.timestamp.key, date as NSDate)
        }
    }
    
    static func nonNilUser() -> Filtering<EventType> {
        return Filtering<EventType> {
            return NSPredicate(format: "%K != nil", Property.Event.user.key)
        }
    }
    
}

extension Sorting where T == EventType {
    
    static func timestamp(ascending: Bool) -> Sorting<EventType> {
        return Sorting<EventType> {
            return SortingDescriptor(key: Property.Event.timestamp.key, ascending: ascending)
        }
    }
    
}
