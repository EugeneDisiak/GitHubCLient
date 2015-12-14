//
//  Repository.swift
//  GitHubClient
//
//  Created by Evgeniy Disyak on 12/2/15.
//  Copyright © 2015 Evgeniy Disyak. All rights reserved.
//

import Foundation
import ObjectMapper

/* JSON object with required data
[
    {
        "id": 1296269,
        "owner": {
            "login": "octocat",
            "id": 1,
            "avatar_url": "https://github.com/images/error/octocat_happy.gif",
        },
        "name": "Hello-World",
        "full_name": "octocat/Hello-World",
        "description": "This your first repo!",
        "url": "https://api.github.com/repos/octocat/Hello-World",
        "forks_count": 9, - ??? changed to "forks" seems
        "subscribers_url": "http://api.github.com/repos/octocat/Hello-World/subscribers",
    }
]
*/

class Repository: Mappable {
    var id: Int?
    var owner: RepositoryOwner?
    var name: String?
    var fullName: String?
    var description: String?
    var url: String?
    var forksCount: Int?
    var subscribersURL: String?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        owner           <- map["owner"]
        name            <- map["name"]
        fullName        <- map["full_name"]
        description     <- map["description"]
        url             <- map["url"]
        forksCount      <- map["forks"]
        subscribersURL  <- map["subscribers_url"]
    }
}

class RepositoryOwner: Mappable {
    var id: Int?
    var login: String?
    var avatarURL: String?
    
    required convenience init?(_ map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        id              <- map["id"]
        login           <- map["login"]
        avatarURL       <- map["avatar_url"]
    }
}