//
//  Answer.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class Answer : Codable {
    var owner : User?
    var isAccepted : Bool
    var score : Int
    var creationDate : Int // unix epoch time
    var answerId : Int
    var questionId : Int
    var body : String
    var comments : [Comment]?
    
    enum CodingKeys: String, CodingKey {
        case owner
        case isAccepted = "is_accepted"
        case score
        case creationDate = "creation_date"
        case questionId = "question_id"
        case answerId = "answer_id"
        case body
        case comments
    }
}
