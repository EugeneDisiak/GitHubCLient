//
//  API.swift
//  GitHubClient
//
//  Created by Evgeniy Disyak on 12/2/15.
//  Copyright © 2015 Evgeniy Disyak. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper

public class API {

    static let requestURL = "https://api.github.com/"
    
    /*
     Get list of Repositories
     
     :param: completion - with optional Array of Repository objects or optional Error
     
    */
    
    static func getRepositories(completion:(([Repository]?, NSError?) -> Void)?) {
        
        let moduleURL = requestURL + "user/repos?access_token=\(GitHubManager.sharedInstance.OAuthToken!)"
        
        GitHubManager.sharedInstance.alamofireManager().request(.GET, moduleURL)
            .validate()
            .responseSwiftyJSON(completionHandler: { (request, response, json, error) -> Void in
                
                guard error == nil else {
                    completion?(nil, error as? NSError)
                    return
                }
                
                // Getting array of objects from JSON
                guard let repositories = json.array else {
                    return
                }
                
                // Mapping object from array of JSON objects
                var mappedObjects = [Repository]()
                for repositoriesJSON in repositories {
                    if let suggestion = Mapper<Repository>().map(repositoriesJSON.rawValue) {
                        mappedObjects.append(suggestion)
                    }
                }
                completion?(mappedObjects,nil)
            })
    }
    
    /*
    Get list of Subscribers for Repository
    
    :param: repositorySubscribersURL - String of URL got getting of subscribers
    :param: completion - with optional Array of Subscriber objects or optional Error
    
    */
    
    static func getSubscribersByURL(repositorySubscribersURL: String, completion:(([Subscriber]?, NSError?) -> Void)?) {
    
        GitHubManager.sharedInstance.alamofireManager().request(.GET, repositorySubscribersURL)
            .validate()
            .responseSwiftyJSON(completionHandler: { (request, response, json, error) -> Void in
                
                guard error == nil else {
                    completion?(nil, error as? NSError)
                    return
                }

                // Getting array of objects from JSON
                guard let repositories = json.array else {
                    return
                }

                // Mapping object from array of JSON objects
                var mappedObjects = [Subscriber]()
                for repositoriesJSON in repositories {
                    if let suggestion = Mapper<Subscriber>().map(repositoriesJSON.rawValue) {
                        mappedObjects.append(suggestion)
                    }
                }
                completion?(mappedObjects,nil)
        })
    }
}