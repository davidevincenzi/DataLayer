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
    func makeResultsController(_ entityName: String, predicate: NSPredicate?, sorted: Sorted?) -> ResultsController?
    
    
    // MARK: - Contexts
    
    /// Main view context.
    var mainContext: StorageContext { get }
    
    /// Shared backround context (always the same instance).
    var sharedBackgroundContext: StorageContext { get }
    
    /// Unique backround context (always a new instance).
    var uniqueBackgroundContext: StorageContext { get }
}
