//
//  User.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class User : ShallowUser
{
    // MARK: - Properties returned from API call
    
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
    
    private enum CodingKeys : String, CodingKey
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
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.reputation = try? container.decode(Int.self, forKey: .reputation)
        self.aboutMe = try? container.decode(String.self, forKey: .aboutMe)
        self.age = try? container.decode(Int.self, forKey: .age)
        self.answerCount = try? container.decode(Int.self, forKey: .answerCount)
        self.badgeCounts = try container.decode(BadgeCount.self, forKey: .badgeCounts)
        self.creationDate = try container.decode(Int.self, forKey: .creationDate)
        self.lastAccessDate = try? container.decode(Int.self, forKey: .lastAccessDate)
        self.location = try? container.decode(String.self, forKey: .location)
        self.questionCount = try? container.decode(Int.self, forKey: .questionCount)
        self.viewCount = try? container.decode(Int.self, forKey: .viewCount)
        self.websiteUrl = try? container.decode(String.self, forKey: .websiteUrl)
        
        try super.init(from: decoder)
    }
}
