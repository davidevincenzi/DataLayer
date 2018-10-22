//
//  MasterViewController.swift
//  DataLayer
//
//  Created by Davide Vincenzi on 15.10.18.
//

import UIKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    var dataLayer: DataLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject))
        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        dataLayer?.dataChanged = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc private func insertNewObject() {
        var user = dataLayer?.createUser()
        user?.name = String.random()
        var event = dataLayer?.createEvent()
        event?.user = user
        
        dataLayer?.save()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = dataLayer?.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataLayer?.numberOfEvents() ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if let event = dataLayer?.object(at: indexPath) {
            configureCell(cell, withEvent: event)
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let event = dataLayer?.object(at: indexPath) {
                dataLayer?.deleteEvent(event)
                dataLayer?.save()
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent event: EventType) {
        cell.textLabel!.text = event.timestamp!.description
    }
}

extension String {
    static func random() -> String {
        let length = 15
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomCharacters = (0..<length).map{_ in characters.randomElement()!}
        let randomString = String(randomCharacters)
        
        return randomString
    }
}
