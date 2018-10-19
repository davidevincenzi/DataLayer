//
//  DetailViewDataSource.swift
//  DataLayer
//
//  Created by Aleksander Kovacic on 19.10.18.
//

import Foundation
import CoreData

class DetailViewDataSource: DetailViewDataLayer {
    
    var dataChanged: (() -> Void)?
    
    var detailItem: EventType?
    var userItem: UserType?
    
    private var event: Event
    private var dataLayer: DataLayer
    
    init(event: Event, dataLayer: DataLayer) {
        self.event = event
        self.dataLayer = dataLayer
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewContextSaved),
                                               name: NSNotification.Name.NSManagedObjectContextDidSave,
                                               object: dataLayer.moc)
        
        reloadDetailData()
    }
    
    @objc private func viewContextSaved() {
        reloadDetailData()
        dataChanged?()
    }
    
    private func reloadDetailData() {
        let detail = EventStruct(event: event)
        detailItem = detail
        
        userItem = nil
        if let user = dataLayer.userOfEvent(event) {
            userItem = UserStruct(user: user)
        }
    }
    
    func updateEvent(timestamp: Date) {
        guard let detail = detailItem as? EventStruct else { return }
        
        dataLayer.updateEvent(detail.event, timestamp: timestamp)
        dataLayer.save()
    }
    
}
