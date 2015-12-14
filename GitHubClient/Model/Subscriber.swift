//
//  Subscriber.swift
//  GitHubClient
//
//  Created by Evgeniy Disyak on 12/3/15.
//  Copyright © 2015 Evgeniy Disyak. All rights reserved.
//

import Foundation
import ObjectMapper

/* JSON object with required data
{
    "id" : 14246554,
    "login" : "EugeneDisiak",
    "avatar_url" : "https:\/\/avatars.githubusercontent.com\/u\/14246554?v=3",
}
*/

class Subscriber: Mappable {
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