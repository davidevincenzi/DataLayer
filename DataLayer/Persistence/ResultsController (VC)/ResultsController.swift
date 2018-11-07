//
//  ResultsController.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation

protocol ResultsController {
    /// Called when data has changed.
    var dataChanged: (() -> Void)? { get set }
    
    /// Model object at the specified index path.
    func object(at indexPath: IndexPath) -> Storable?
    
    /// Total number of model objects at the specified section.
    func objectCount(at section: Int) -> Int
    
    /// Total number of model objects.
    var objectCount: Int { get }
    
    /// Total number of model sections.
    var sectionCount: Int { get }
        
}
