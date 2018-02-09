//
//  BriefQuestion.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/7/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

struct BriefQuestion : Codable
{
    var title : String
    var isAnswered : Bool
    var score : Int
    var owner : ShallowUser?
    var creationDate : Int // unix epoch time
    var questionId : Int
    
    enum CodingKeys: String, CodingKey
    {
        case isAnswered = "is_answered"
        case creationDate = "creation_date"
        case questionId = "question_id"
        case title
        case score
        case owner
    }
}
