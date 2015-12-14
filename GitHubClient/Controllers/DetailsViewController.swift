//
//  DetailsViewController.swift
//  GitHubClient
//
//  Created by Evgeniy Disyak on 12/3/15.
//  Copyright © 2015 Evgeniy Disyak. All rights reserved.
//

import Foundation

import UIKit

private let placeholderImage: UIImage = {
    let img = UIImage(named: "avatarPlaceholder")!
    return img
}()

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var subscribersCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var repository: Repository!
    var subscribers = [Subscriber]()
 

// MARK: - Life cycle    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = repository.name
        
        API.getSubscribersByURL(repository.subscribersURL!) { [weak self] subscribers, error in
        
            if let subscribers = subscribers {
                // Uptade DataSource and reload TableView
                self?.subscribers = subscribers
                self?.tableView.reloadData()
                self?.subscribersCountLabel.text = "\(subscribers.count)"
            } else {
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribersCountLabel.text = "0"
        fullNameLabel.text = repository.fullName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetailsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscribers.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultSubscriberCell", forIndexPath: indexPath) as! DefaultSubscriberCell
        let subscriber = subscribers[indexPath.row]
        
        if let subscriberAvatarURL = subscriber.avatarURL, let imageURL = NSURL(string:subscriberAvatarURL) {
            cell.avatarImageView?.af_setImageWithURL(imageURL, placeholderImage: placeholderImage)
        } else {
            cell.avatarImageView?.image = placeholderImage
        }
        
        cell.nameLabel.text = subscriber.login
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}
