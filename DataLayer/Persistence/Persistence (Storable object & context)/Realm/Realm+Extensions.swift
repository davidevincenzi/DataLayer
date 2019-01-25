//
//  Realm+Extensions.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation


// MARK: Define Data Layer type
let dataLayerType: DataLayerType = .realm


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

extension UserRealm: UserType {}

extension EntityName {
    static var user: String = "UserRealm"
}

extension Property {
    struct User {}
}
extension Property.User where T == UserType, U == String {
    static var id: Property = .init(key: "id")
    static var remoteID: Property = .init(key: "remoteId")
    static var name: Property = .init(key: "name")
}
extension Property.User where T == UserType, U == EventType {
    static var events: Property = .init(key: "events")
}


// MARK: - Event

extension EventRealm: EventType {}

extension EntityName {
    static var event: String = "EventRealm"
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
    static var remoteID: Property = .init(key: "remoteId")
}
extension Property.Event where T == EventType, U == Date {
    static var timestamp: Property = .init(key: "timestamp")
}
extension Property.Event where T == EventType, U == UserType {
    static var user: Property = .init(key: "user")
}

