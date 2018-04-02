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
    // MARK: - Properties returned from API call
    
    var tags : [String]?
    var comments : [Comment]?
    var answers : [Answer]? = nil
    var owner : ShallowUser?
    var isAnswered : Bool = false
    var score : Int = 0
    var creationDate : Int = 0
    var title : String?
    var body : String = ""
    var acceptedAnswerId : Int?
    var closedDate : Int?
    var closedReason : String?
    var questionId : Int = 0
    
    // MARK: - Coding Keys
    
    private enum CodingKeys: String, CodingKey
    {
        case isAnswered = "is_answered"
        case creationDate = "creation_date"
        case acceptedAnswerId = "accepted_answer_id"
        case closedDate = "closed_date"
        case closedReason = "closed_reason"
        case questionId = "question_id"
        case tags
        case comments
        case answers
        case owner
        case score
        case title
        case body
    }
    
    // MARK: - Helper properties
    var isCommentsCollapsed = false
}
