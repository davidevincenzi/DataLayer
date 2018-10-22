//
//  ResultsController.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation

protocol ResultsController {
    associatedtype T where T: Storable
    
    /// STILL WORKING ON THIS!
    
    var dataChanged: (() -> Void)? { get set }
    
    func object(at indexPath: IndexPath) -> EventType
    func numberOfEvents() -> Int
    
//    func create<T: Storable>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws
//
//    func delete(object: Storable) throws
//
//    func save(object: Storable) throws
    
    var context: ReadableStorageContext { get }
    
    var writableContext: WritableStorageContext? { get }
}

//class DefaultResultsController: ResultsController {
//
//}
