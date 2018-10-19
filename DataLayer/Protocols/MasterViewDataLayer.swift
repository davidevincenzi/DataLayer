//
//  MasterViewDataLayer.swift
//  DataLayer
//
//  Created by Aleksander Kovacic on 19.10.18.
//

import Foundation

protocol MasterViewDataLayer {
    var dataChanged: (() -> Void)? { get set }
    func numberOfEvents() -> Int
    func object(at indexPath: IndexPath) -> EventType
    func createEvent(creator: String)
    func deleteEvent(_ event: EventType)
    func detailViewDataLayerForEvent(_ event: EventType) -> DetailViewDataLayer
}
