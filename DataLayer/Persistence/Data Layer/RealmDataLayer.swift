//
//  RealmDataLayer.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation
import RealmSwift

class RealmDataLayer: NSObject, DataLayer {
    
    
    // MARK: - Contexts
    
    /// The main context, has the persistent store as parent.
    lazy var mainContext: StorageContext = {
        return try! Realm()
    }()
    
    
    // MARK: - Results Controller
    
    func makeResultsController<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, sectionNameKeyPath: String?, fetchBatchSize: Int?, cacheName: String?) -> ResultsController? {
        guard
            let storing = storing as? Storing<Object>,
            let filtering = filtering as? Filtering<Object>?,
            let sorting = sorting as? [Sorting<Object>]?
            else { return nil }
        
        return RealmResultsController(storing, filtering: filtering, sorting: sorting, context: mainContext, sectionNameKeyPath: sectionNameKeyPath, fetchBatchSize: fetchBatchSize, cacheName: cacheName)
    }
}
