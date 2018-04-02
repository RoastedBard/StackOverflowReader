//
//  AuthorizationManager.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/7/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class AuthorizationManager
{
    // MARK : Properties
    
    static var authorizedUser : IntermediateUser?
    
    fileprivate static let accesTokenAccountString = "access_token"
    
    static fileprivate(set) var isAuthorized : Bool
    {
        get {
            if accessToken != nil {
                return true
            } else {
                return false
            }
        }
        
        set {}
    }
    
    static fileprivate(set) var accessToken : String?
    {
        get {
            let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
            
            if hasLogin == true {
                do {
                    let accessTokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                               account: accesTokenAccountString,
                                                               accessGroup: KeychainConfiguration.accessGroup)
                    
                    let accessToken = try accessTokenItem.readPassword()
                    
                    return accessToken
                } catch {
                    fatalError("Error reading password from keychain - \(error)")
                }
            }
            
            return nil
        }
        
        set(newAccessToken) {
            guard let newAccessToken = newAccessToken else {
                return
            }
            
            saveAccessToken(newAccessToken)
        }
    }
    
    // MARK : Public methods
    
    static func login(urlWithAccessToken : String? = nil, completion : @escaping () -> Void)
    {
        if self.accessToken == nil, urlWithAccessToken == nil {
            // Unable to login
            return
        }
        
        if self.accessToken == nil {
            guard let url = urlWithAccessToken, let accessToken = Utility.parseUrlForValue(url: url, valueForKey: "access_token") else {
                print("Unable to extract access token from url")
                print("url: \(urlWithAccessToken!)")
                return
            }
            
            APICallHelper.APICall(request: APIRequestType.ValidateAccessTokenRequest, apiCallParameter: accessToken) { (apiWrapperResult : APIResponseWrapper<AccessTokenInfo>?) in
                if apiWrapperResult?.items == nil {
                    print("Access token is not valid")
                    return
                } else {
                    self.accessToken = accessToken
                    
                    self.isAuthorized = true
                    
                    // Get user stack overflow data
                    APICallHelper.APICall(request: APIRequestType.MyAccountRequest, apiCallParameter: AuthorizationManager.accessToken){ (apiWrapperResult : APIResponseWrapper<User>?) in
                        guard let userModel = apiWrapperResult?.items?[0] else {
                            print("Failed to convert user model to intermediate model")
                            return
                        }
                        
                        self.authorizedUser = IntermediateUser(userModel)
                    }
                    
                    completion()
                }
            }
        } else {
            self.isAuthorized = true
            
            // Get user stack overflow data
            APICallHelper.APICall(request: APIRequestType.MyAccountRequest, apiCallParameter: AuthorizationManager.accessToken){ (apiWrapperResult : APIResponseWrapper<User>?) in
                guard let userModel = apiWrapperResult?.items?[0] else {
                    print("Failed to convert user model to intermediate model")
                    return
                }
                
                self.authorizedUser = IntermediateUser(userModel)
            }
            
            completion()
        }
    }
    
    static func logout(completion : @escaping () -> Void)
    {
        if self.isAuthorized == true {
            APICallHelper.APICall(request: APIRequestType.LogOutRequest, apiCallParameter: AuthorizationManager.accessToken){ (apiWrapperResult : APIResponseWrapper<LogOutResponse>?) in
                
                // De-authorize
                removeAccessToken()
                
                // Clear cookies
                deleteCookies()
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                // Save context
                appDelegate.dataController.saveContext()
                
                // Clear search history
                SearchHistoryManager.searchHistory.removeAll()
                
                self.isAuthorized = false
                
                completion()
            }
        } else {
            completion()
        }
    }
    
    static func deleteCookies()
    {
        let dataStore = WKWebsiteDataStore.default()
        
        dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                if record.displayName.contains("facebook") || record.displayName.contains("stackexchange") || record.displayName.contains("stackoverflow"){
                    dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: [record], completionHandler: {})
                }
            }
        }
    }
    
    // MARK : Fileprivate methods
    
    fileprivate static func saveAccessToken(_ newAccessToken: String) {
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        if hasLogin == false {
            do {
                let accessTokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                           account: accesTokenAccountString,
                                                           accessGroup: KeychainConfiguration.accessGroup)
                
                try accessTokenItem.savePassword(newAccessToken)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
            
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
        }
    }
    
    fileprivate static func removeAccessToken()
    {
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        
        if hasLogin == true {
            do {
                let accessTokenItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                           account: accesTokenAccountString,
                                                           accessGroup: KeychainConfiguration.accessGroup)
                
                try accessTokenItem.deleteItem()
            } catch {
                fatalError("Error reading password from keychain - \(error)")
            }
            
            UserDefaults.standard.set(false, forKey: "hasLoginKey")
        }
    }
}
