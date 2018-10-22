//
//  CoreDataResultsController.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation
import CoreData

class CoreDataResultsController<T: NSManagedObject>: NSObject, ResultsController, NSFetchedResultsControllerDelegate {
    
    
    // MARK: - ResultsController protocol conformance
    
    var dataChanged: (() -> Void)?
    
    func object(at indexPath: IndexPath) -> Storable? {
        return fetchedResultsController?.object(at: indexPath) as? Storable
    }
    
    var objectCount: Int {
        return fetchedResultsController?.sections?.first?.numberOfObjects ?? 0
    }
    
    
    // MARK: - Setup
    
    init(_ model: T.Type, context: ReadableStorageContext, predicate: NSPredicate?, sorted: Sorted?) {
        super.init()
        
        // fetched results controller
        createFetchedResultsController(model, context: context, predicate: predicate, sorted: sorted)
    }
    
    
    // MARK: - Fetched results controller
    
    private var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    private func createFetchedResultsController<T>(_ model: T.Type, context: ReadableStorageContext, predicate: NSPredicate?, sorted: Sorted?) where T: NSManagedObject {
        guard let nativeContext = context as? NSManagedObjectContext else {
            print("Unresolved error: `context` is not an `NSManagedObjectContext`!")
            return
        }
        guard let entityName = model.entity().name else {
            print("`model` is not of `NSManagedObject` type.")
            return
        }
        
        // build fetch request
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        
        // sorting
        if let sort = sorted {
            let sortDescriptor = NSSortDescriptor(key: sort.key, ascending: sort.ascending)
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        // set the batch size to a suitable number
        fetchRequest.fetchBatchSize = 20
        
        // create controller
        if let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: nativeContext, sectionNameKeyPath: nil, cacheName: "Master") as? NSFetchedResultsController<NSFetchRequestResult> {
            fetchedResultsController = controller
            fetchedResultsController?.delegate = self
        }
        else {
            print("Failed to create NSFetchedResultsController")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        dataChanged?()
    }
    
}
