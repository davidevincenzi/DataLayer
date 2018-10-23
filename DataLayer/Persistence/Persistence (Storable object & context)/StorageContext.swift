//
//  StorageContext.swift
//  DataLayer
//
//  Created by Nuno Grilo on 20/10/2018.
//

import Foundation


/**
 * Provides an high-level API for doing persistence operations in context.
 */
 

/// Full-featured storage context.
typealias StorageContext = ReadableStorageContext & WritableStorageContext

/// Read operations, on context.
protocol ReadableStorageContext {
    /// Load an object with the specified ID.
    func loadObject(withId id: AnyObject, completion: @escaping ((Storable?) -> ()))
    
    /// Return a list of objects that are conformed to the `Storable` protocol
    func fetch<T: Storable>(_ entityName: String, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([T]) -> ()))
}

/// Write operations, on context.
protocol WritableStorageContext {
    /// Create a new object with default values that conforms to `Storable` protocol.
    func create(_ entity: Storable.Type, completion: @escaping ((Storable) -> Void)) throws
    
    /// Save
    func saveContext() throws
    
    /// Update an object that is conformed to the `Storable` protocol.
    func update(block: @escaping () -> ()) throws
    
    /// Delete an object that is conformed to the `Storable` protocol
    func delete(_ object: Storable) throws
    
    /// Delete all objects that are conformed to the `Storable` protocol
    func deleteAll(_ entityName: String) throws
}

/// Query options.
public struct Sorted {
    var key: String
    var ascending: Bool = true
}
