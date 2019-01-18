//
//  ResultsController.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation

enum ResultsControllerChangeType {
    case insert
    case move
    case update
    case delete
}

protocol ResultsController {
    
    // MARK: - Data change related.
    
    /// Called when data is about to change.
    var dataWillChange: (() -> Void)? { get set }
    
    /// Called when data has changed.
    var dataChanged: (() -> Void)? { get set }
    
    /// Called when an object has changed.
    var objectChanged: ((_ object: Any, _ indexPath: IndexPath?, _ changeType: ResultsControllerChangeType, _ newIndexPath: IndexPath?) -> Void)? { get set }
    
    /// Called when a section is added or removed.
    var sectionChanged: ((_ sectionIndex: Int, _ changeType: ResultsControllerChangeType) -> Void)? { get set }
    
    
    // MARK: - Objects access.
    
    /// Model object at the specified index path.
    func object(at indexPath: IndexPath) -> Storable?
    
    /// All model objects.
    var allObjects: [Storable] { get }
    
    
    // MARK: Counts.
    
    /// Total number of model objects (at first section).
    var objectCount: Int { get }
    
    /// Total number of model objects at the specified section.
    func objectCount(at section: Int) -> Int
    
    /// Total number of model sections.
    var sectionCount: Int { get }
        
}
