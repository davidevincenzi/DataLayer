//
//  CoreData+Extensions.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation


// MARK: Define Data Layer type
let dataLayerType: DataLayerType = .coreData


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

