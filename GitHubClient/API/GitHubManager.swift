//
//  GitHubManager.swift
//  GitHubClient
//
//  Created by Evgeniy Disyak on 12/2/15.
//  Copyright © 2015 Evgeniy Disyak. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper

class GitHubManager {
    
    static let requestURL = "https://api.github.com/"
    var clientID = "4285568462671202d345"
    var clientSecret = "32f554ac62e20ea388cd04eeee39d6dd4fd69f6c"
    
    static let sharedInstance = GitHubManager()
    
    var OAuthTokenCompletionHandler: (NSError? -> Void)?
    
    var OAuthToken: String? {
        set {
            if let valueToSave = newValue {
                // save to UserDefaults
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(valueToSave, forKey: "gitHubAccessToken")
                addSessionHeader("Authorization", value: "token \(valueToSave)")
            }
            else
            {
                removeSessionHeaderIfExists("Authorization")
            }
        }
        get
        {
            // get from UserDefaults
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let token = userDefaults.valueForKey("gitHubAccessToken") as? String {
                return token
            }
            removeSessionHeaderIfExists("Authorization")
            return nil
        }
    }
    
    init () {
        if tokenExists() {
            addSessionHeader("Authorization", value: "token \(OAuthToken!)")
        }
    }
    
    func alamofireManager() -> Manager {
        let manager = Alamofire.Manager.sharedInstance
        addSessionHeader("Accept", value: "application/vnd.github.v3+json")
        return manager
    }
    
    func tokenExists () -> Bool {
        
        if let token = self.OAuthToken {
            return !token.isEmpty
        }
        return false
    }
    
    func addSessionHeader(key: String, value: String) {
        let manager = Alamofire.Manager.sharedInstance
        
        if var sessionHeaders = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String>
        {
            sessionHeaders[key] = value
            manager.session.configuration.HTTPAdditionalHeaders = sessionHeaders
        }
        else
        {
            manager.session.configuration.HTTPAdditionalHeaders = [
                key: value
            ]
        }
    }
    
    func removeSessionHeaderIfExists(key: String) {
        let manager = Alamofire.Manager.sharedInstance
        if var sessionHeaders = manager.session.configuration.HTTPAdditionalHeaders as? Dictionary<String, String>
        {
            sessionHeaders.removeValueForKey(key)
            manager.session.configuration.HTTPAdditionalHeaders = sessionHeaders
        }
    }
    
    func startAuthorisation() {
        
        let authPath = "https://github.com/login/oauth/authorize?" +
                        "client_id=\(clientID)&scope=repo&state=TEST_STATE"
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let authURL:NSURL = NSURL(string: authPath)
        {
            userDefaults.setBool(true, forKey: "tryingToReceiveGitHubToken")
            UIApplication.sharedApplication().openURL(authURL)
        }
    }
    
    func processAuthorisationResponse(url: NSURL) {
        
        let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
        var authorisationCode: String?
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let queryItems = components?.queryItems {
            for queryItem in queryItems {
                if queryItem.name.lowercaseString == "code" {
                    authorisationCode = queryItem.value
                    break
                }
            }
        }
        
        if let receivedCode = authorisationCode {
            let getGitHubTokenURL = "https://github.com/login/oauth/access_token"
            let gitHubTokenParams = ["client_id": clientID, "client_secret": clientSecret, "code": receivedCode]
            
            Alamofire.request(.POST, getGitHubTokenURL, parameters: gitHubTokenParams, encoding: .URL, headers: nil).responseString { response in
                
                if response.result.isFailure {
                    if let completionHandler = self.OAuthTokenCompletionHandler {
                        completionHandler(response.result.error)
                    }
                    userDefaults.setBool(false, forKey: "tryingToReceiveGitHubToken")
                    return
                }
                
                if let responseString = response.result.value {
                    let resultParams: Array<String> = responseString.componentsSeparatedByString("&")
                    print(resultParams)
                    for resultPair in resultParams {
                        let keyValuePair: Array<String> = resultPair.componentsSeparatedByString("=")
                        
                        // we are looking for access_token, but we can handle other params if it will be required
                        if keyValuePair[0].lowercaseString == "access_token" {
                            self.OAuthToken = keyValuePair[1]
                            break
                        }
                    }
                    
                    userDefaults.setBool(false, forKey: "tryingToReceiveGitHubToken")
                    if self.tokenExists() {
                        if let completionHandler = self.OAuthTokenCompletionHandler {
                            completionHandler(nil)
                        }
                    } else {
                        if let completionHandler = self.OAuthTokenCompletionHandler {
                            
                            let noOAuthTokenError = NSError(domain: "Access Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not possible to get GitHub OAuth token", NSLocalizedRecoverySuggestionErrorKey: "Try again later"])
                            
                            completionHandler(noOAuthTokenError)
                        }
                    }
                }
            }
        } else {
            // no code received
            userDefaults.setBool(false, forKey: "tryingToReceiveGitHubToken")
        }
    }
}