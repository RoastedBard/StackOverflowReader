//
//  Comment.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

// Здесь с наследованием все работает, видимо из-за отстутствия optional'ов, хотя наследование ShallowUser -> User работает корректно при наличии всех видов и типов данных в обеих классах
class Comment : CommonModelData
{
    //var owner : ShallowUser?
    //var score : Int
    //var creationDate : Int // unix epoch time
    var postId : Int
    var commentId : Int
    //var body : String
    
    private enum CodingKeys : String, CodingKey
    {
        //case creationDate = "creation_date"
        case postId = "post_id"
        case commentId = "comment_id"
        //case owner
        //case score
        //case body
    }
    
    // MARK: - init
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.commentId = try container.decode(Int.self, forKey: .commentId)
        
        try super.init(from: decoder)
    }
}
