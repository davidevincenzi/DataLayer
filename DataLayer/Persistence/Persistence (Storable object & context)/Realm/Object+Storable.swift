//
//  Object+Storable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 18/01/2019.
//

import RealmSwift

extension Object: Storable {
    
    var storageContext: StorageContext? {
        return realm
    }
    
}
