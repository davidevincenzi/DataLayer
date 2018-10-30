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
            var _name: String?
            managedObjectContext?.performAndWait { [ weak self] in
                _name = self?.cd_name
            }
            return _name
        }
        set {
            managedObjectContext?.performAndWait { [ weak self] in
                self?.cd_name = newValue
            }
        }
    }
    
    
}

extension Storing where T == UserType {
    
    static var userType: Storing<UserType> {
        return Storing<UserType>(entityName: "User")
    }
    
}
