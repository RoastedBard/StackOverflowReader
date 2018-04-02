//
//  AccessTokenInfo.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/8/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import Foundation

struct AccessTokenInfo : Codable
{
    // MARK: - Properties returned from API call
    
    var accountId : Int
    var expiresOnDate : Int?
    var scope : [String]
    
    // MARK: - Coding Keys
    
    enum CodingKeys : String, CodingKey
    {
        case accountId = "account_id"
        case expiresOnDate = "expires_on_date"
        case scope
    }
}
