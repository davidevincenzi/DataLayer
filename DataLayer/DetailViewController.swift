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
                detailDescriptionLabel.text = detail.timestamp!.description
            }
            if let userLabel = self.userLabel {
                userLabel.text = detail.creator?.name
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
            // Update the view.
            configureView()
        }
    }

    @IBAction func refreshButtonAction(_ sender: Any) {
        configureView()
    }
    
}

