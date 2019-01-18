//
//  RealmResultsController.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

//class RealmResultsController: ResultsController {
//
//    // TODO: use Realm conform to our `ResultsController` protocol
//    // Check https://redbooth.com/engineering/ios/realmresultscontroller
//
//}

import Foundation
import RealmSwift

class RealmResultsController<T: Object>: NSObject, ResultsController {
    
    var storing: Storing<T>
    var filtering: Filtering<T>?
    var sorting: [Sorting<T>]?
    var context: ReadableStorageContext
    var sectionNameKeyPath: String?
    var fetchBatchSize: Int?
    var cacheName: String?

    // MARK: - ResultsController protocol conformance

    var storageContext: ReadableStorageContext {
        return context
    }

    private var results: Results<T>?
    private var observerToken: NotificationToken?

    var dataWillChange: (() -> Void)?
    var dataChanged: (() -> Void)?
    var objectChanged: ((_ object: Any, _ indexPath: IndexPath?, _ changeType: ResultsControllerChangeType, _ newIndexPath: IndexPath?) -> Void)?
    var sectionChanged: ((_ sectionIndex: Int, _ changeType: ResultsControllerChangeType) -> Void)?

    func object(at indexPath: IndexPath) -> Storable? {
        guard indexPath.section < sectionCount && indexPath.row < objectCount(at: indexPath.section) else { return nil }
        return results?[indexPath.row] as? Storable
    }

    var allObjects: [Storable] {
        guard let results = resultsController else { return [] }
        return Array(results) as? [Storable] ?? []
    }

    func indexPath(for object: Storable) -> IndexPath? {
        guard let object = object as? T else { return nil }
        guard let row = resultsController?.index(of: object) else { return nil }

        return IndexPath(row: row, section: 0)
    }

    func objectCount(at section: Int) -> Int {
        return resultsController?.count ?? 0
    }

    var objectCount: Int {
        return resultsController?.count ?? 0
    }

    var sectionCount: Int {
        // FIXME: section count must retunr # of sections!!!
        return 1
        //return resultsController?.sections?.count ?? 1
    }


    // MARK: - Setup

    init(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, context: ReadableStorageContext, sectionNameKeyPath: String? = nil, fetchBatchSize: Int?, cacheName: String?) {
        self.storing = storing
        self.filtering = filtering
        self.sorting = sorting
        self.context = context
        self.sectionNameKeyPath = sectionNameKeyPath

        super.init()
    }
    
    deinit {
        observerToken = nil
    }


    // MARK: - Fetched results controller

    private lazy var resultsController: Results<T>? = {
        guard let nativeContext = context as? Realm else {
            print("Unresolved error: `context` is not a `Realm`!")
            return nil
        }

        var results = nativeContext.objects(T.self)

        // filtering
        if let predicate = filtering?.filter() {
            results = results.filter(predicate)
        }

        // sorting
        let sortDescriptors: [SortDescriptor]? = sorting?.map {
            let sort = $0.sortDescriptor()
            return SortDescriptor(keyPath: sort.key, ascending: sort.ascending)
        }
        if let sortDescriptors = sortDescriptors {
            results = results.sorted(by: sortDescriptors)
        }
        
        // `fetchBatchSize`: `Result` are lazy evaluated
        // `cacheName`: no equivalent on Realm
        
        // notifications
        observerToken = registerForNotifications(results)
        
        return results
    }()
    
    private func registerForNotifications<T>(_ results: Results<T>) -> NotificationToken {
        let observer = results.observe { [weak self] changes in
            switch changes {
            case .initial(_):
                // initial run of the query has completed and the collection can now be used without performing any blocking work
                break
            case .update(_, let deletions, let insertions, let modifications):
                // a write transaction has been committed
                self?.dataWillChange?()
                
                // TODO: handle section, on code below
                deletions.forEach { indexInt in
                    let indexPath = IndexPath(item: indexInt, section: 0)
                    if let object = self?.object(at: indexPath) {
                        self?.objectChanged?(object, nil, .delete, indexPath)
                    }
                }
                insertions.forEach { indexInt in
                    let indexPath = IndexPath(item: indexInt, section: 0)
                    if let object = self?.object(at: indexPath) {
                        self?.objectChanged?(object, nil, .insert, indexPath)
                    }
                }
                modifications.forEach { indexInt in
                    let indexPath = IndexPath(item: indexInt, section: 0)
                    if let object = self?.object(at: indexPath) {
                        self?.objectChanged?(object, nil, .update, indexPath)
                    }
                }
                print("deletions: \(deletions), insertions: \(insertions), modifications: \(modifications)")
                
                self?.dataChanged?()
                break
            case .error:
                break
            }
        }

        return observer
    }
    
    // FIXME: `sectionChanged()` (addition/removal of section) never called

//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        sectionChanged?(sectionIndex, ResultsControllerChangeType(fetchedResultsChangeType: type))
//    }

}
