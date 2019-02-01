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
    
    func uniqueBackgroundContext(_ debugName: String) -> StorageContext {
        // TODO: this may not work: a `Realm` must be confined to the thread in which was created!
        return try! Realm(configuration: (mainContext as! Realm).configuration)
    }
    
    // MARK: - Results Controller
    
    func makeResultsController<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, sectionNameKeyPath: String?, fetchBatchSize: Int?, cacheName: String?) -> ResultsController? {
        return RealmResultsController(storing, filtering: filtering, sorting: sorting, context: mainContext, sectionNameKeyPath: sectionNameKeyPath, fetchBatchSize: fetchBatchSize, cacheName: cacheName)
    }
}
