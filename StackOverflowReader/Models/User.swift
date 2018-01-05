//
//  User.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class User : Codable {
    var reputation : Int?
    var userId : Int?
    var userType : String
    var profileImage : String?
    var displayName : String?
    var link : String?
    
    enum CodingKeys : String, CodingKey {
        case userId = "user_id"
        case userType = "user_type"
        case profileImage = "profile_image"
        case displayName = "display_name"
        case link
        case reputation
    }
}
