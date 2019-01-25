//
//  UserType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 17.10.18.
//

import Foundation

// MARK: - UserType Protocol

protocol UserType: Storable {
    var id: String? { get set }
    var remoteId: String? { get set }
    var name: String? { get set }
    
    var events: [EventType]? { get set }
}

extension UserType {
    
    var remoteId: String? {
        get {
            return object(forProperty: Property.User.remoteID)
        }
        set {
            setObject(newValue, forProperty: Property.User.remoteID)
        }
    }
    
    var name: String? {
        get {
            return object(forProperty: Property.User.name)
        }
        set {
            setObject(newValue, forProperty: Property.User.name)
        }
    }
    
    var events: [EventType]? {
        get {
            return list(forProperty: Property.User.events)
        }
        set {
            setList(newValue, forProperty: Property.User.events)
        }
    }
}

// MARK: - Storing

extension Storing where T == UserType {
    static var user: Storing<UserType> {
        return Storing<UserType>(entityName: EntityName.user, updateableProperties: [
            Property.User.id,
            Property.User.remoteID,
            Property.User.events,
            ])
    }
}
