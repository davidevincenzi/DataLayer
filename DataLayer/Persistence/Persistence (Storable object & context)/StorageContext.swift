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
    /// Asynchronously load an object with the specified ID.
    func loadObject(withId id: AnyObject, completion: @escaping ((Storable?) -> ()))
    
    /// Synchronously load an object with the specified ID.
    func loadObject(withId id: AnyObject) -> Storable?
    
    /// Asynchronously return a list of objects that are conformed to the `Storable` protocol
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, completion: @escaping (([T]) -> ()))
    
    /// Synchronously return a list of objects that are conformed to the `Storable` protocol
    func fetch<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?) -> [T]
}

/// Write operations, on context.
protocol WritableStorageContext {
    /// Create a new object with default values that conforms to `Storable` protocol.
    func create<T>(_ storing: Storing<T>, completion: @escaping ((T) -> Void)) throws

    /// Save
    func saveContext() throws
    
    /// Update an object that is conformed to the `Storable` protocol.
    func update(block: @escaping () -> ()) throws
    
    /// Delete an object that is conformed to the `Storable` protocol
    func delete(_ object: Storable) throws
    
    /// Delete all objects that are conformed to the `Storable` protocol
    func deleteAll<T>(_ storing: Storing<T>) throws
}

/// Query options.

struct Storing<T> {
    var type: T.Type {
        return T.self
    }
    var entityName: String
}

struct Filtering<T> {
    let filter: () -> NSPredicate
}

struct Sorting<T> {
    let sortDescriptor: () -> SortingDescriptor
}

struct SortingDescriptor {
    var key: String
    var ascending: Bool = true
}
