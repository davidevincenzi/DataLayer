//
//  DataLayer.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

enum DataLayerType {
    case coreData
    case realm
}

protocol DataLayer {
    
    // MARK: - Results Controller
    
    /// Create a ResultsController
    func makeResultsController<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, sectionNameKeyPath: String?, fetchBatchSize: Int?, cacheName: String?) -> ResultsController?
    
    
    // MARK: - Contexts
    
//    /// Main view context (read-only).
//    var mainContext: ReadableStorageContext { get }
//
//    /// Write context (read-write).
//    var writableContext: StorageContext { get }
    
    /// Main view context.
    var mainContext: StorageContext { get }
    
    /// Unique backround context (always a new context instance).
    func uniqueBackgroundContext(_ debugName: String) -> StorageContext
    
    /// Perform a task in context, without waiting for the task to finish.
    func performInBackground(_ objects: [Storable?], block: @escaping ([Storable?]) -> ())
    
}

protocol HasDataLayer {
    var dataLayer: DataLayer { get }
}

extension DataLayer {

    func makeResultsController<T>(_ storing: Storing<T>, filtering: Filtering<T>? = nil, sorting: [Sorting<T>]? = nil, sectionNameKeyPath: String? = nil, fetchBatchSize: Int? = 20, cacheName: String? = nil) -> ResultsController? {
        return makeResultsController(storing, filtering: filtering, sorting: sorting, sectionNameKeyPath: sectionNameKeyPath, fetchBatchSize: fetchBatchSize, cacheName: cacheName)
    }
    
    func performInBackground(_ objects: [Storable?], block: @escaping ([Storable?]) -> ()) {
        performInBackground(objects, block: block)
    }

}
