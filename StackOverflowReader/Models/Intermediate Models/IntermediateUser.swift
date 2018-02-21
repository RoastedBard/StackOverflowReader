//
//  IntermediateUser.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class IntermediateUser : IntermediateShallowUser
{
    var reputation : Int?
    var aboutMe : NSAttributedString?
    var age : Int?
    var answerCount : Int?
    var badgeCount : IntermediateBadgeCount
    var creationDate : Int // unix epoch time
    var lastAccessDate : Int? // unix epoch time
    var location : NSAttributedString?
    var questionCount : Int?
    var viewCount : Int?
    var websiteUrl : String?
    
    init(_ user : User)
    {
        if let reputation = user.reputation {
            self.reputation = reputation
        }
        
        if let aboutMe = user.aboutMe?.htmlAttributedString {
            self.aboutMe = aboutMe
        }
        
        if let age = user.age {
            self.age = age
        }
        
        if let answerCount = user.answerCount {
            self.answerCount = answerCount
        }
        
        self.badgeCount = IntermediateBadgeCount(user.badgeCounts)
        
        self.creationDate = user.creationDate
        
        if let lastAccessDate = user.lastAccessDate {
            self.lastAccessDate = lastAccessDate
        }
        
        if let location = user.location?.htmlAttributedString {
            self.location = location
        }
        
        if let questionCount = user.questionCount {
            self.questionCount = questionCount
        }
        
        if let viewCount = user.viewCount {
            self.viewCount = viewCount
        }
        
        if let websiteUrl = user.websiteUrl {
            self.websiteUrl = websiteUrl
        }
        
        super.init(userId: user.userId ?? -1, profileImage: user.profileImage ?? "", displayName: user.displayName ?? "")
    }
}
