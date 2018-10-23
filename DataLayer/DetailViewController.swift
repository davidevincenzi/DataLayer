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
    
    var dataLayer: DetailViewDataLayer?
    
    func configureView() {
        // Update the user interface for the detail item.
        detailDescriptionLabel?.text = dataLayer?.detailItem?.timestamp?.description
        userLabel?.text = dataLayer?.userItem?.name
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        dataLayer?.dataChanged = { [weak self] in
            self?.configureView()
        }
        configureView()
    }

    @IBAction func updateTimestampAndRefresh(_ sender: Any) {
        let newDate = Date()
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.dataLayer?.updateEvent(timestamp: newDate)
        }
    }
    
    @IBAction func refreshButtonAction(_ sender: Any) {
        configureView()
    }
    
    @IBAction func backgroundButtonAction(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            print("Date: \(String(describing: self.dataLayer?.detailItem?.timestamp))")
        }
    }
    
}

