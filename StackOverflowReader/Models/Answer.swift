//
//  Answer.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class Answer : Codable //CommonModelData
{
    // MARK: - Properties returned from API call
    
    var owner : ShallowUser? // COMMON Закомментировать, если наследоваться CommonModelData
    var isAccepted : Bool
    var score : Int // COMMON Закомментировать, если наследоваться CommonModelData
    var creationDate : Int // COMMON Закомментировать, если наследоваться CommonModelData // unix epoch time
    var answerId : Int
    var body : String // COMMON Закомментировать, если наследоваться CommonModelData
    var comments : [Comment]?
    
    private enum CodingKeys: String, CodingKey
    {
        case owner // COMMON Закомментировать, если наследоваться CommonModelData
        case isAccepted = "is_accepted"
        case score // COMMON Закомментировать, если наследоваться CommonModelData
        case creationDate = "creation_date" // COMMON Закомментировать, если наследоваться CommonModelData
        case answerId = "answer_id"
        case body // COMMON Закомментировать, если наследоваться CommonModelData
        case comments
    }
    
    // MARK: - Helper properties
    
    var isCommentsCollapsed = false
    
    // MARK: - init

// Раскомментировать, если наследоваться от CommonModelData
    
//    required init(from decoder: Decoder) throws
//    {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.isAccepted = try container.decode(Bool.self, forKey: .isAccepted)
//        self.answerId = try container.decode(Int.self, forKey: .answerId)
//        self.comments = try? container.decode([Comment].self, forKey: .comments)
//
//        try super.init(from: decoder)
//    }
}
