//
//  NSManagedObject+Storable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 18/01/2019.
//

import CoreData

extension NSManagedObject: Storable {
    
    var storageContext: StorageContext? {
        return managedObjectContext
    }
    
}
