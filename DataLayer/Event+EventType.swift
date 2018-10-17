//
//  Event+EventType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

extension Event: EventType {
    var creator: UserType? {
        get {
            return user
        }
        set {
            if let user = newValue as? User {
                self.user = user
            }
        }
    }
}
