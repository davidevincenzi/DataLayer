//
//  CoreData+Extensions.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation

// MARK: - Storable

extension Storing {
    static func defaultIsDeletedProperty() -> PropertyProtocol {
        return Property<Storable, Storable>(key: "is_deleted")
    }
    
    static func defaultLastModifiedProperty() -> PropertyProtocol {
        return Property<Storable, Storable>(key: "modified")
    }
    
    static func defaultRemotePrimaryProperty() -> PropertyProtocol {
        return Property<Storable, Storable>(key: "id")
    }
    
    static func defaultLocalPrimaryProperty() -> PropertyProtocol {
        return Property<Storable, Storable>(key: "remoteID")
    }
}

// Common filtering
extension Filtering where T == Storable {
    static func ids<T>(type: Storing<T>, ids: [String]) -> Filtering<T> {
        return Filtering<T> {
            guard let primaryKey = type.localPrimaryProperty?.key else { return NSPredicate(value: true) }
            return NSPredicate(format: "%K IN %@", primaryKey, ids)
        }
    }
    
    static func id<T>(type: Storing<T>, id: String) -> Filtering<T> {
        return Filtering<T> {
            guard let primaryKey = type.localPrimaryProperty?.key else { return NSPredicate(value: true) }
            return NSPredicate(format: "%K = %@", primaryKey, id)
        }
    }
    
    static func id<T>(type: Storing<T>, id: Int) -> Filtering<T> {
        return Filtering<T> {
            guard let primaryKey = type.localPrimaryProperty?.key else { return NSPredicate(value: true) }
            return NSPredicate(format: "%K = %d", primaryKey, id)
        }
    }
    
    static func markedAsDeleted<T>(type: Storing<T>) -> Filtering<T> {
        return Filtering<T> {
            return NSPredicate(format: "%K = 1", type.isDeletedProperty.key)
        }
    }
    
    static func notMarkedAsDeleted<T>(type: Storing<T>) -> Filtering<T> {
        return Filtering<T> {
            return NSPredicate(format: "%K != 1", type.isDeletedProperty.key)
        }
    }
}


// MARK: - User

extension User: UserType {}

extension EntityName {
    static var user: String = "User"
}

extension Property {
    struct User {}
}
extension Property.User where T == UserType, U == String {
    static var id: Property = .init(key: "id")
    static var remoteID: Property = .init(key: "cd_remote_id")
    static var name: Property = .init(key: "cd_name")
}
extension Property.User where T == UserType, U == EventType {
    static var events: Property = .init(key: "cd_events")
}


// MARK: - Event

extension Event: EventType {}

extension EntityName {
    static var event: String = "Event"
}

extension Filtering where T == UserType {
    //    static func room(roomID: String) -> Filtering<UserType> {
    //        return Filtering<MinuteNoteProtocol> {
    //            return NSPredicate(format: "room_id = %@", roomID)
    //        }
    //    }
}

extension Property {
    struct Event {}
}
extension Property.Event where T == EventType, U == String {
    static var id: Property = .init(key: "id")
    static var remoteID: Property = .init(key: "cd_remote_id")
}
extension Property.Event where T == EventType, U == Date {
    static var timestamp: Property = .init(key: "cd_timestamp")
}
extension Property.Event where T == EventType, U == UserType {
    static var user: Property = .init(key: "cd_user")
}

