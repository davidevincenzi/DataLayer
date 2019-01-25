//
//  Results+Storable.swift
//  DataLayer
//
//  Created by Nuno Grilo on 25/01/2019.
//

import Foundation
import RealmSwift

protocol StorableResults {
    func object(at index: Int) -> Storable?
    var count: Int { get }
}

extension Results: StorableResults {
    func object(at index: Int) -> Storable? {
        return self[index] as? Storable
    }
}
