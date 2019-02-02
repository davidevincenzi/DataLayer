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
    
    /// This must be called from the thread the Realm will operate on.
    func uniqueBackgroundContext(_ debugName: String) -> StorageContext {
        let config = mainConfiguration
        return try! Realm(configuration: config)
    }
    
    func performInBackground(_ objects: [Storable?], block: @escaping ([Storable?]) -> ()) {
        // get object references (on current thread)
        let refs: [ThreadSafeReference<Object>] = objects.compactMap {
            guard let obj = $0 as? Object else { return nil }
            return ThreadSafeReference<Object>(to: obj)
        }
        // get `main` realm configuration
        let config = mainConfiguration
        
        // on background thread...
        backgroundQueue.async {
            autoreleasepool {
                do {
                    // create a new realm, on bg thread
                    let realm = try! Realm(configuration: config)
                    let realmObjects = refs.compactMap { realm.resolve($0) }
                    
                    // changes done on this bg context are automatically
                    // propagated to others, by Realm
                    try realm.write {
                        // call block with objects valid for this thread
                        block(realmObjects as? [Storable] ?? [])
                    }
                } catch {
                    #warning ("do something to catch the error")
                }
            }
        }
    }
    
    private var mainConfiguration: Realm.Configuration {
        var config: Realm.Configuration!
        
        if Thread.isMainThread {
            config = (mainContext as! Realm).configuration
        } else {
            DispatchQueue.main.sync {
                config = (mainContext as! Realm).configuration
            }
        }
        
        return config
    }
    
    private lazy var backgroundQueue: DispatchQueue = {
        return DispatchQueue(label: "Data Layer Background Queue", qos: .background)
    }()
    
    
    // MARK: - Results Controller
    
    func makeResultsController<T>(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, sectionNameKeyPath: String?, fetchBatchSize: Int?, cacheName: String?) -> ResultsController? {
        return RealmResultsController(storing, filtering: filtering, sorting: sorting, context: mainContext, sectionNameKeyPath: sectionNameKeyPath, fetchBatchSize: fetchBatchSize, cacheName: cacheName)
    }
}
