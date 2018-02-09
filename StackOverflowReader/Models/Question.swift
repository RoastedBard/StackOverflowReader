//
//  Question.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class Question : Codable //CommonModelData
{
    // MARK: - Properties returned from API call
    
    var tags : [String]
    var comments : [Comment]? = nil
    var answers : [Answer]? = nil
    var owner : ShallowUser? // COMMON Закомментировать, если наследоваться CommonModelData
    var isAnswered : Bool
    var score : Int // COMMON Закомментировать, если наследоваться CommonModelData
    var creationDate : Int // unix epoch time // COMMON Закомментировать, если наследоваться CommonModelData
    var title : String
    var body : String // COMMON Закомментировать, если наследоваться CommonModelData
    var acceptedAnswerId : Int?
    var closedDate : Int?
    var closedReason : String?
    
    private enum CodingKeys: String, CodingKey
    {
        case isAnswered = "is_answered"
        case creationDate = "creation_date" // COMMON Закомментировать, если наследоваться CommonModelData
        case acceptedAnswerId = "accepted_answer_id"
        case closedDate = "closed_date"
        case closedReason = "closed_reason"
        case tags
        case comments
        case answers
        case owner // COMMON Закомментировать, если наследоваться CommonModelData
        case score // COMMON Закомментировать, если наследоваться CommonModelData
        case title
        case body // COMMON Закомментировать, если наследоваться CommonModelData
    }
    
    // MARK: - Helper properties
    
    var isCommentsCollapsed = false
    
    // MARK: - init
    
// Раскомментировать, если наследоваться от CommonModelData
    
//    required init(from decoder: Decoder) throws
//    {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        self.tags = try container.decode([String].self, forKey: .tags)
//        self.comments = try? container.decode([Comment].self, forKey: .comments)
//        self.answers = try? container.decode([Answer].self, forKey: .answers)
//        self.isAnswered = try container.decode(Bool.self, forKey: .isAnswered)
//        self.title = try container.decode(String.self, forKey: .title)
//        self.acceptedAnswerId = try? container.decode(Int.self, forKey: .acceptedAnswerId)
//        self.closedDate = try? container.decode(Int.self, forKey: .closedDate)
//        //try container.decodeIfPresent(String.self, forKey: .closedReason)
//        self.closedReason = try? container.decode(String.self, forKey: .closedReason)
//
//        try super.init(from: decoder)
//    }
}
