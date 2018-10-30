//
//  Event+EventType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

extension Event: EventType {
    
    var user: UserType? {
        get {
            var _user: UserType?
            managedObjectContext?.performAndWait { [ weak self] in
                _user = self?.cd_user
            }
            return _user
        }
        set {
            managedObjectContext?.performAndWait { [ weak self] in
                if let user = newValue as? User {
                    self?.cd_user = user
                }
            }
        }
    }
    
    var timestamp: Date? {
        get {
            var _timestamp: Date?
            managedObjectContext?.performAndWait { [ weak self] in
                _timestamp = self?.cd_timestamp
            }
            return _timestamp
        }
        set {
            managedObjectContext?.performAndWait { [ weak self] in
                self?.cd_timestamp = newValue
            }
        }
    }
}

extension Storing where T == EventType {
    
    static var eventType: Storing<EventType> {
        return Storing<EventType>(entityName: "Event")
    }
    
}

extension Filtering where T == EventType {
    
    static func timestamp(largerThan date: Date) -> Filtering<EventType> {
        return Filtering<EventType> {
            return NSPredicate(format: "cd_timestamp > %@", date as NSDate)
        }
    }
    
}

extension Sorting where T == EventType {
    
    static func timestamp(ascending: Bool) -> Sorting<EventType> {
        return Sorting<EventType> {
            return SortingDescriptor(key: "cd_timestamp", ascending: ascending)
        }
    }
    
}
