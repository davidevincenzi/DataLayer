//
//  MasterViewDataSource.swift
//  DataLayer
//
//  Created by Aleksander Kovacic on 19.10.18.
//

import Foundation
import CoreData

class MasterViewDataSource: MasterViewDataLayer {
    
    var dataChanged: (() -> Void)?
    
    private var dataLayer: DataLayer
    private var allEvents: [EventStruct] = []
    
    init(dataLayer: DataLayer) {
        self.dataLayer = dataLayer
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewContextSaved),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: dataLayer.moc)
        
        loadEvents()
    }
    
    @objc private func viewContextSaved() {
        loadEvents()
        dataChanged?()
    }
    
    private func loadEvents() {
        let events = dataLayer.loadEvents()
        
        // Instead of overwriting allEvents we could calculate the diff here
        // and notify which events exactly were created/deleted/updated
        // so we can make use of partial table reload (and cell animations)
        allEvents = events.map({ EventStruct(event: $0) })
        
        dataChanged?()
    }
    
    func numberOfEvents() -> Int {
        return allEvents.count
    }
    
    func object(at indexPath: IndexPath) -> EventType {
        return allEvents[indexPath.row]
    }
    
    func createEvent(creator: String) {
        dataLayer.createEvent(creator: creator)
        dataLayer.save()
    }
    
    func deleteEvent(_ event: EventType) {
        guard let eventStruct = event as? EventStruct else { fatalError("Event must be an EventStruct") }
        
        dataLayer.deleteEvent(eventStruct.event)
        dataLayer.save()
    }
    
    func detailViewDataLayerForEvent(_ event: EventType) -> DetailViewDataLayer {
        guard let eventStruct = event as? EventStruct else { fatalError("Event must be an EventStruct") }
        
        let detailViewDataLayer = DetailViewDataSource(event: eventStruct.event, dataLayer: dataLayer)
        return detailViewDataLayer
    }
    
}
