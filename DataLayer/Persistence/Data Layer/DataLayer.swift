//
//  DataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

protocol DataLayer {
    
    // MARK: - Results Controller
    
    /// Create a ResultsController
    func makeResultsController<T: Storable>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?) -> ResultsController?
    
    
    // MARK: - Setup
    
    /// Load the underlying persistent store.
    func load(completion: ((Error?) -> Void)?)
    
    
    // MARK: - Contexts
    
    /// Main view context (read-only).
    var mainContext: ReadableStorageContext { get }
    
    /// Write context (read-write).
    var writableContext: WritableStorageContext { get }
}

protocol HasDataLayer {
    var dataLayer: DataLayer { get }
}


extension DataLayer {
    func load(completion: ((Error?) -> Void)? = nil) {
        load(completion: completion)
    }
    
    func makeResultsController<T: Storable>(_ model: T.Type, predicate: NSPredicate? = nil, sorted: Sorted? = nil) -> ResultsController? {
        return makeResultsController(model, predicate: predicate, sorted: sorted)
    }
}
