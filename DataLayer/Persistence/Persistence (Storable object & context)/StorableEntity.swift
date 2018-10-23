//
//  StorableEntity.swift
//  DataLayer
//
//  Created by Nuno Grilo on 22/10/2018.
//

import Foundation

//enum StorableEntity: String {
//    case user = "User"
//    case event = "Event"
//}

/// Ideally, `EventType` could conform to `Storable` and implement `entityName`.
///
/// The problem is that it's not possible to call a staic variable like `EventType.entityName`
/// due to the fact that `EventType` is a protocol
