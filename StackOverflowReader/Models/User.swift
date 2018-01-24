//
//  User.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class User : Codable
{
    var reputation : Int?
    var aboutMe : String?
    var age : Int?
    var answerCount : Int?
    var badgeCounts : BadgeCount
    var creationDate : Int // unix epoch time
    var lastAccessDate : Int? // unix epoch time
    var location : String?
    var questionCount : Int?
    var viewCount : Int?
    var websiteUrl : String?
    
    enum CodingKeys : String, CodingKey
    {
        case aboutMe = "about_me"
        case answerCount = "answer_count"
        case badgeCounts = "badge_counts"
        case creationDate = "creation_date"
        case lastAccessDate = "last_access_date"
        case questionCount = "question_count"
        case viewCount = "view_count"
        case websiteUrl = "website_url"
        case age
        case reputation
        case location
    }
}
