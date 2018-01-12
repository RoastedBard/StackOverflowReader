//
//  Question.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class Question : Codable
{
    var tags : [String]
    var comments : [Comment]? = nil
    var answers : [Answer]? = nil
    var owner : User?
    var isAnswered : Bool
    var score : Int
    var creationDate : Int // unix epoch time
    var questionId : Int
    var title : String
    var body : String
    var acceptedAnswerId : Int?
    var closedDate : Int?
    var closedReason : String?
    var link : String
    
    enum CodingKeys: String, CodingKey
    {
        case isAnswered = "is_answered"
        case creationDate = "creation_date"
        case questionId = "question_id"
        case acceptedAnswerId = "accepted_answer_id"
        case closedDate = "closed_date"
        case closedReason = "closed_reason"
        case tags
        case comments
        case answers
        case owner
        case score
        case title
        case body
        case link
    }
}
