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
    func makeResultsController(_ entityType: Storable.Type, predicate: NSPredicate?, sorted: Sorted?) -> ResultsController?
    
    
    // MARK: - Contexts
    
    /// Main view context (read-only).
    var mainContext: ReadableStorageContext { get }
    
    /// Write context (read-write).
    var writableContext: StorageContext { get }
}

protocol HasDataLayer {
    var dataLayer: DataLayer { get }
}
