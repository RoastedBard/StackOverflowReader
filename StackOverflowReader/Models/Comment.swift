//
//  Comment.swift
//  ConsolePlayground
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class Comment : Codable
{
    var owner : ShallowUser?
    var score : Int
    var creationDate : Int // unix epoch time
    var postId : Int
    var commentId : Int
    var body : String
    
    enum CodingKeys : String, CodingKey
    {
        case creationDate = "creation_date"
        case postId = "post_id"
        case commentId = "comment_id"
        case owner
        case score
        case body
    }
}
