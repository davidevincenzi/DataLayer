////
////  RealmResultsController.swift
////  DataLayer
////
////  Created by Nuno Grilo on 22/10/2018.
////
//
//import Foundation
//
////class RealmResultsController: ResultsController {
////    
////    // TODO: use Realm conform to our `ResultsController` protocol
////    // Check https://redbooth.com/engineering/ios/realmresultscontroller
////    
////}
//
//import RealmSwift
//
//class RealmResultsController<T: Object>: NSObject, ResultsController {
//    
//    var storing: Storing<T>
//    var filtering: Filtering<T>?
//    var sorting: [Sorting<T>]?
//    var context: ReadableStorageContext
//    var sectionNameKeyPath: String?
//    var fetchBatchSize: Int?
//    var cacheName: String?
//    
//    // MARK: - ResultsController protocol conformance
//    
//    var storageContext: ReadableStorageContext {
//        return context
//    }
//    
//    private var results: Results<T>?
//    
//    var dataWillChange: (() -> Void)?
//    var dataChanged: (() -> Void)?
//    var objectChanged: ((_ object: Any, _ indexPath: IndexPath?, _ changeType: ResultsControllerChangeType, _ newIndexPath: IndexPath?) -> Void)?
//    var sectionChanged: ((_ sectionIndex: Int, _ changeType: ResultsControllerChangeType) -> Void)?
//    
//    func object(at indexPath: IndexPath) -> Storable? {
//        guard indexPath.section < sectionCount && indexPath.row < objectCount(at: indexPath.section) else { return nil }
//        return results?[indexPath.row] as? Storable
//    }
//    
//    var allObjects: [Storable] {
//        guard let results = results else { return [] }
//        return Array(results) as? [Storable] ?? []
//    }
//    
//    func indexPath(for object: Storable) -> IndexPath? {
//        guard let object = object as? T else { return nil }
//        guard let row = resultsController?.index(of: object) else { return nil }
//        
//        return IndexPath(row: row, section: 0)
//    }
//    
//    func objectCount(at section: Int) -> Int {
//        return resultsController?.count ?? 0
//    }
//    
//    var objectCount: Int {
//        return resultsController?.count ?? 0
//    }
//    
//    var sectionCount: Int {
//        return fetchedResultsController?.sections?.count ?? 1
//    }
//    
//    
//    // MARK: - Setup
//    
//    init(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: [Sorting<T>]?, context: ReadableStorageContext, sectionNameKeyPath: String? = nil, fetchBatchSize: Int?, cacheName: String?) {
//        self.storing = storing
//        self.filtering = filtering
//        self.sorting = sorting
//        self.context = context
//        self.sectionNameKeyPath = sectionNameKeyPath
//        
//        super.init()
//    }
//    
//    
//    // MARK: - Fetched results controller
//    
//    private lazy var resultsController: Results<T>? = {
//        guard let nativeContext = context as? Realm else {
//            print("Unresolved error: `context` is not a `Realm`!")
//            return nil
//        }
//        
//        var results = nativeContext.objects(T.self)
//        
//        if let predicate = filtering?.filter() {
//            results = results.filter(predicate)
//        }
//        
//        // sorting
//        if let sort = sorting?.sortDescriptor() {
//            results = results.sorted(byKeyPath: sort.key, ascending: sort.ascending)
//        }
//        
//        return results
//    }()
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        dataWillChange?()
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        dataChanged?()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        objectChanged?(anObject, indexPath, ResultsControllerChangeType(fetchedResultsChangeType: type), newIndexPath)
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        sectionChanged?(sectionIndex, ResultsControllerChangeType(fetchedResultsChangeType: type))
//    }
//    
//}
//
//extension ResultsControllerChangeType {
//    
//    init(fetchedResultsChangeType: NSFetchedResultsChangeType) {
//        switch fetchedResultsChangeType {
//        case .insert:
//            self = .insert
//        case .move:
//            self = .move
//        case .update:
//            self = .update
//        case .delete:
//            self = .delete
//        }
//    }
//    
//}
