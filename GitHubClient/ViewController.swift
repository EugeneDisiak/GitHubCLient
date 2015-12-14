//
//  ViewController.swift
//  GitHubClient
//
//  Created by Evgeniy Disyak on 12/1/15.
//  Copyright © 2015 Evgeniy Disyak. All rights reserved.
//

import UIKit
import AlamofireImage

private let placeholderImage: UIImage = {
    let img = UIImage(named: "imagePlaceholder")!
    return img
}()

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var repositories = [Repository]()

// MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if !userDefaults.boolForKey("tryingToReceiveGitHubToken") {
            loadInitialData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

// MARK: - Methods
    
    func getRepositories() {
        API.getRepositories { [weak self] repositories, error in
            
            if let repositories = repositories {
                // Uptade DataSource and reload TableView
                self?.repositories = repositories
                self?.tableView.reloadData()
                
            } else {
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
        }
    }

    func loadInitialData() {
        if (!GitHubManager.sharedInstance.tokenExists()) {
            
            GitHubManager.sharedInstance.OAuthTokenCompletionHandler = { [weak self] (error) -> Void in
                if let error = error {
                    print(error)
                } else {
                    self?.getRepositories()
                }
            }
            GitHubManager.sharedInstance.startAuthorisation()
        } else {
            getRepositories()
        }
    }
    
}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.repositories.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DefaultCell", forIndexPath: indexPath) as! DefaultCell
        let repository = repositories[indexPath.row]
        
        if let repositoryImageURL = repository.owner?.avatarURL, let imageURL = NSURL(string:repositoryImageURL) {
            cell.avatarImageView?.af_setImageWithURL(imageURL, placeholderImage: placeholderImage)
        } else {
            cell.avatarImageView?.image = placeholderImage
        }
        
        cell.nameLabel.text = repository.name
        cell.fullNameLabel.text = repository.fullName
        cell.descriptionLabel.text = repository.description
        if let forksCount = repository.forksCount {
            cell.numberofForksLabel.text = "\(forksCount)"
        } else {
            cell.numberofForksLabel.text = "0"
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
}

// MARK: - Navigation
extension ViewController {
    
    enum Segue : String {
        case ToRepositoryDetails = "toRepositoryDetails"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let segueID = segue.identifier, segueType = Segue(rawValue: segueID)
            else { return }
        
        switch segueType {
        case .ToRepositoryDetails:
            
            let detailsController = segue.destinationViewController as! DetailsViewController
            if let cell = sender as? DefaultCell {
                let indexPath = tableView.indexPathForCell(cell)
                detailsController.repository = repositories[indexPath!.row]
            }
        }
    }
}