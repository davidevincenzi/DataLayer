//
//  ThreadSafeType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 18.10.18.
//

import CoreData

protocol ThreadSafeType {
    func executeThreadSafe(block: (() -> Void))
}

extension ThreadSafeType {
    func executeThreadSafe(block: (() -> Void)) {
        guard let moc = (self as? NSManagedObject)?.managedObjectContext else { return }
        
        moc.performAndWait {
            block()
        }
    }
}
