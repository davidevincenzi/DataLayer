//
//  DetailViewDataLayer.swift
//  DataLayer
//
//  Created by Aleksander Kovacic on 19.10.18.
//

import Foundation

protocol DetailViewDataLayer {
    var dataChanged: (() -> Void)? { get set }
    var detailItem: EventType? { get }
    var userItem: UserType? { get }
    func updateEvent(timestamp: Date)
}
