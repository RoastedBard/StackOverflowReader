//
//  Answer.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class Answer : Codable
{
    // MARK: - Properties returned from API call
    var owner : ShallowUser?
    var isAccepted : Bool
    var score : Int = 0
    var creationDate : Int = 0 // unix epoch time
    var answerId : Int
    var body : String = ""
    var comments : [Comment]?
    
    private enum CodingKeys: String, CodingKey
    {
        case owner
        case isAccepted = "is_accepted"
        case score
        case creationDate = "creation_date"
        case answerId = "answer_id"
        case body
        case comments
    }
    
    // MARK: - Helper properties
    
    var isCommentsCollapsed = false
}
