//
//  LogOutResponse.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/5/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import Foundation

class LogOutResponse : Codable
{
    var accountId : Int = 0
    var expiresOnDate : Int = 0
    var accessToken : String = ""
    
    enum CodingKeys : String, CodingKey
    {
        case accountId = "account_id"
        case expiresOnDate = "expires_on_date"
        case accessToken = "access_token"
    }
}
