//
//  UserAnswer.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/29/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class UserAnswer : Codable
{
    // MARK: - Properties returned from API call
    
    var answerId : Int
    var questionId : Int
    
    // MARK: - Coding Keys
    
    enum CodingKeys : String, CodingKey
    {
        case answerId = "answer_id"
        case questionId = "question_id"
    }
}
