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
    
    var dataLayer: DataLayer?
    
    func configureView() {
        // Update the user interface for the detail item.
        detailDescriptionLabel?.text = detailItem?.timestamp?.description
        userLabel?.text = userItem?.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }

    var userItem: UserType?
    
    var detailItem: EventType? {
        didSet {
            if let detail = detailItem {
                userItem = dataLayer?.userOfEvent(detail)
            } else {
                userItem = nil
            }
            configureView()
        }
    }

    @IBAction func refreshButtonAction(_ sender: Any) {
        configureView()
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            print("Date: \(String(describing: self.detailItem?.timestamp))")
        }
    }
    
}

