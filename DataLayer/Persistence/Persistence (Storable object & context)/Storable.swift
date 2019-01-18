//
//  Storable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//

import Foundation

///// Umbrella protocol for all storable protocols
//protocol Storable {
//
//}

/// Umbrella protocol for all storable protocols
protocol Storable: class {
    
    /// Returns the object associated storage context.
    var storageContext: StorageContext? { get }
    
    /// Returns the primary key of the Storable. Default is nil. It should be overridden by the protocol that inherits to Storable.
    static func primaryKey() -> String?
    
    /// Returns a mutable set proxy that provides read-write access to the unordered to-many relationship specified by a given key.
    /// See description of `mutableSetValue(forKey:)` in `NSKeyValueCoding` (`NSManagedObject`)
    func mutableSetValue(forKey: String) -> NSMutableSet
}

extension Storable {
    static func primaryKey() -> String? {
        return nil
    }
    
    func replaceObjects(_ array: [Storable], forKey: String) {
        let items = self.mutableSetValue(forKey: forKey);
        items.removeAllObjects()
        items.addObjects(from: array)
    }
}

// MARK: - Access by property.

extension Storable where Self: NSObject {
    func object<T, U>(forProperty property: Property<T, U>) -> U? {
        let object = value(forKey: property.key)
        return object as? U
    }
    
    func setObject<T, U>(_ object: U?, forProperty property: Property<T, U>) {
        setValue(object, forKey: property.key)
    }
    
    func list<T, U>(forProperty property: Property<T, U>) -> [U]? {
        let object = value(forKey: property.key)
        guard let set = object as? Set<NSObject> else {
            print("Storable.list(\(self).\(property.key)) failed: relationship value is not `Set<NSObject>`")
            return nil
        }
        return Array(set) as? [U]
    }
    
    func setList<T, U>(_ objects: [U]?, forProperty property: Property<T, U>) {
        if let array = objects as? [NSObject] {
            setValue(Set(array), forKey: property.key)
        } else {
            setValue(nil, forKey: property.key)
        }
    }
}
