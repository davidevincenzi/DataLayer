//
//  CoreDataResultsController.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation
import CoreData

class CoreDataResultsController<T>: NSObject, ResultsController, NSFetchedResultsControllerDelegate {
    
    var storing: Storing<T>
    var filtering: Filtering<T>?
    var sorting: Sorting<T>?
    var context: ReadableStorageContext
    var sectionNameKeyPath: String?
    
    // MARK: - ResultsController protocol conformance
    
    var dataWillChange: (() -> Void)?
    var dataChanged: (() -> Void)?
    var objectChanged: ((_ object: Any, _ indexPath: IndexPath?, _ changeType: ResultsControllerChangeType, _ newIndexPath: IndexPath?) -> Void)?
    var sectionChanged: ((_ sectionIndex: Int, _ changeType: ResultsControllerChangeType) -> Void)?
    
    func object(at indexPath: IndexPath) -> Storable? {
        return fetchedResultsController?.object(at: indexPath) as? Storable
    }
    
    func objectCount(at section: Int) -> Int {
        guard section < fetchedResultsController?.sections?.count ?? 1 else { return 0 }
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    var objectCount: Int {
        return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }
    
    var sectionCount: Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    
    // MARK: - Setup

    init(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, context: ReadableStorageContext, sectionNameKeyPath: String? = nil) {
        self.storing = storing
        self.filtering = filtering
        self.sorting = sorting
        self.context = context
        self.sectionNameKeyPath = sectionNameKeyPath
        
        super.init()
    }
    
    
    // MARK: - Fetched results controller
    
    private lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = {
        guard let nativeContext = context as? NSManagedObjectContext else {
            print("Unresolved error: `context` is not an `NSManagedObjectContext`!")
            return nil
        }
        
        let entityName = storing.entityName
        
        // build fetch request
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        
        // filtering
        fetchRequest.predicate = filtering?.filter()
        
        // sorting
        if let sort = sorting?.sortDescriptor() {
            let sortDescriptor = NSSortDescriptor(key: sort.key, ascending: sort.ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        // set the batch size to a suitable number
        fetchRequest.fetchBatchSize = 20
        
        // create controller
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: nativeContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: "Master") as? NSFetchedResultsController<NSFetchRequestResult>
        controller?.delegate = self
        
        do {
            try controller?.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataWillChange?()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataChanged?()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        objectChanged?(anObject, indexPath, ResultsControllerChangeType(fetchedResultsChangeType: type), newIndexPath)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        sectionChanged?(sectionIndex, ResultsControllerChangeType(fetchedResultsChangeType: type))
    }
    
}

extension ResultsControllerChangeType {
    
    init(fetchedResultsChangeType: NSFetchedResultsChangeType) {
        switch fetchedResultsChangeType {
        case .insert:
            self = .insert
        case .move:
            self = .move
        case .update:
            self = .update
        case .delete:
            self = .delete
        }
    }
    
}
