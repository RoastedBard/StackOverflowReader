//
//  ShallowUser.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/24/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class ShallowUser : Codable
{
    var userId : Int?
    var profileImage : String?
    var displayName : String?
    
    enum CodingKeys : String, CodingKey
    {
        case userId = "user_id"
        case profileImage = "profile_image"
        case displayName = "display_name"
    }
}
