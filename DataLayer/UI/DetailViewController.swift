//
//  DetailViewController.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            if let detailDescriptionLabel = self.detailDescriptionLabel {
                detailDescriptionLabel.text = detail.timestamp?.description ?? "-"
            }
            if let userLabel = self.userLabel {
                userLabel.text = detail.user?.name
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var detailItem: EventType? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                // Update the view.
                self?.configureView()
            }
        }
    }

    @IBAction func refreshButtonAction(_ sender: Any) {
        configureView()
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
//        // This works with CoreData *ONLY*! :/
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            self?.detailItem?.storageContext?.performInContext {
//                print("Date: \(String(describing: self?.detailItem?.timestamp))")
//            }
//        }
        
//        // This works -> but.. how to adapt to our current generic DataLayer API?
//        // (force-casting everywhere)
//        let ref = ThreadSafeReference(to: detailItem as! Object)
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            autoreleasepool {
//                let context = self?.dataLayer?.uniqueBackgroundContext("Background access")
//                let detailItem = (context as! Realm).resolve(ref)
//                context?.performInContext {
//                    print("Date: \(String(describing: (detailItem as! EventType).timestamp))")
//                }
//            }
//        }
        
        // NEW API: works for both CoreData & Realm
        detailItem?.storageContext?.performInBackground([detailItem]) { objects in
            guard let detailItem = objects.first as? EventType else { return }
            print("Date: \(String(describing: detailItem.timestamp))")
        }
    }
    
    @IBAction func updateTimestampAndRefresh(_ sender: Any) {
//        // This works with CoreData *ONLY*! :/
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            self?.detailItem?.storageContext?.performInContext {
//                self?.detailItem?.timestamp = Date()
//            }
//        }
        
//        // This works with *both* -> but.. how to adapt to our current generic DataLayer API?
//        // -> get object ref (ThreadSafeReference on Realm, ObjectID on CD)
//        let ref = ThreadSafeReference(to: detailItem as! Object)
//        DispatchQueue.global(qos: .background).async { [weak self] in
//            autoreleasepool {
//                let context = self?.dataLayer?.uniqueBackgroundContext("Background access")
//                // -> get object from object ref, on new thread and realm (using the same conf)
//                let detailItem = (context as! Realm).resolve(ref) as! EventType
//                context?.performInContext {
//                    detailItem.timestamp = Date()
//                }
//                // and if we want to persist (not on the AEL case)
//                try? context?.saveContext()
//            }
//        }
        
        // NEW API: works for both CoreData & Realm
        detailItem?.storageContext?.performInBackground([detailItem]) { objects in
            guard let detailItem = objects.first as? EventType else { return }
            detailItem.timestamp = Date()
        }
        
        configureView()
    }
}

