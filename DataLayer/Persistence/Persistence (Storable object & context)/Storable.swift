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

}

/// Core Data `NSManagedObject` compliance to `Storable` protocol.
extension NSManagedObject: Storable {}

/// Realm `Object` compliance to `Storable` protocol.
//extension Object: Storable {}
