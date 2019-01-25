//
//  Object+Storable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 18/01/2019.
//

import RealmSwift

extension Object {
    
    /// Storable Note:
    ///  Although `NSManagedObject` provides the required function implementations
    ///     required by the `Storable` protocol, instances of NSManagedObject conform
    ///     to `Storable` protocol *only* when a specific `xxxx` managed model object
    ///     conforms to the `xxxxProtocol` protocol model.
    ///  Example:
    ///  ```
    ///      protocol xxxxProtocol: Storable {}
    ///      extension xxx: xxxxProtocol {}
    ///  ```
    
    var storageContext: StorageContext? {
        return realm
    }
    
}
