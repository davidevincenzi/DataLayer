//
//  EventType.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import Foundation

protocol EventType: Storable {
    var timestamp: Date? { get set }
    var user: UserType? { get set }
}
