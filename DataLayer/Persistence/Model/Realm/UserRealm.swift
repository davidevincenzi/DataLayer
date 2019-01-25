//
//  UserRealm.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation
import RealmSwift

class UserRealm: Object {
    @objc dynamic var id: String?
    @objc dynamic var remoteId: String?
    @objc dynamic var name: String?
    
    let events = List<EventRealm>()
}
