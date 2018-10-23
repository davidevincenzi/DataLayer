//
//  Event+EventType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

extension Event: EventType {
    static var entityName: String {
        return "Event"
    }
    
    
    var user: UserType? {
        get {
            return cd_user
        }
        set {
            if let user = newValue as? User {
                self.cd_user = user
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
