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
    // MARK: - Properties returned from API call
    
    var owner : ShallowUser?
    var score : Int = 0
    var creationDate : Int = 0 // unix epoch time
    var postId : Int = 0
    var commentId : Int = 0
    var body : String = ""
    
    private enum CodingKeys : String, CodingKey
    {
        case creationDate = "creation_date"
        case postId = "post_id"
        case commentId = "comment_id"
        case owner
        case score
        case body
    }
}
