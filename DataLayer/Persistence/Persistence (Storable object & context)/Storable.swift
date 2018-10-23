//
//  Storable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//

import Foundation
import CoreData

/// Protocol for storable objects (e.g., Core Data NSManagedObject, Realm Object)
protocol Storable {
    static var entityName: String { get }
    var storableId: AnyObject { get }
}

/// Core Data `NSManagedObject` compliance to `Storable` protocol.
extension NSManagedObject {
    
    var storableId: AnyObject {
        return objectID
    }
}

/// Realm `Object` compliance to `Storable` protocol.
//extension Object: Storable {
//    var entityName: String {
//        return ______
//    }
//}
