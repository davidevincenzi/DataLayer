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
    
    // MARK: - ResultsController protocol conformance
    
    var dataChanged: (() -> Void)?
    
    func object(at indexPath: IndexPath) -> Storable? {
        return fetchedResultsController?.object(at: indexPath) as? Storable
    }
    
    var objectCount: Int {
        return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }
    
    
    // MARK: - Setup

    init(_ storing: Storing<T>, filtering: Filtering<T>?, sorting: Sorting<T>?, context: ReadableStorageContext) {
        self.storing = storing
        self.filtering = filtering
        self.sorting = sorting
        self.context = context
        
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
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: nativeContext, sectionNameKeyPath: nil, cacheName: "Master") as? NSFetchedResultsController<NSFetchRequestResult>
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataChanged?()
    }
    
}
