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
}

/// Core Data `NSManagedObject` compliance to `Storable` protocol.
extension NSManagedObject: Storable {
    static var entityName: String {
        return self.entity().name!
    }
}

/// Realm `Object` compliance to `Storable` protocol.
//extension Object: Storable {
//    var entityName: String {
//        return ______
//    }
//}
