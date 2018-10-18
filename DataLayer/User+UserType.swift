//
//  User+UserType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 17.10.18.
//

import Foundation

extension User: UserType {
    var name: String? {
        get {
            return cd_name
        }
        set {
            self.cd_name = newValue
        }
    }
    
    
}
