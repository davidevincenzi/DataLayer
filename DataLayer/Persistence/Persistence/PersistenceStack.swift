//
//  PersistenceStack.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation

protocol PersistenceStack {
    
    // MARK: - Setup
    
    /// Load the underlying persistent store.
    func load(completion: ((Error?) -> Void)?)
    
    
    // MARK: - Contexts
    
    /// Main view context (read-only).
    var readableContext: ReadableStorageContext { get }
    
    /// Write context (read-write).
    var writableContext: WritableStorageContext { get }
    
}

extension PersistenceStack {
    func load(completion: ((Error?) -> Void)? = nil) {
        load(completion: completion)
    }
}
