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
            return cd_timestamp
        }
        set {
            cd_timestamp = newValue
        }
    }
}
