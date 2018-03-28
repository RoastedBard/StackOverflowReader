//
//  IntermediateComment.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

class IntermediateComment : IntermediateCommon
{
    // MARK: - Properties
    
    var postId : Int = 0
    var commentId : Int = 0
    
    // MARK: - Init
    
    init(_ comment : Comment, contentWidth: CGFloat)
    {
        self.postId = comment.postId
        self.commentId = comment.commentId
        
        super.init(shallowUser: comment.owner, score: comment.score, creationDate: comment.creationDate, body: comment.body, contentWidth: contentWidth)
    }
    
    init(_ comment : CommentMO, contentWidth: CGFloat)
    {
        self.postId = Int(comment.postId)
        self.commentId = Int(comment.commentId)
        
        super.init(shallowUser: comment.owner, score: Int(comment.score), creationDate: Int(comment.creationDate), body: comment.body ?? "", contentWidth: contentWidth)
    }
}
