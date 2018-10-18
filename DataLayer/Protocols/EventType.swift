//
//  EventType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

protocol EventType: ThreadSafeType {
    var timestamp: Date? { get set }
    var user: UserType? { get set }
}
