//
//  IntermediateAnswer.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

class IntermediateAnswer : IntermediateCommon
{
    // MARK: - Properties
    
    var isAccepted : Bool
    var answerId : Int
    var comments : [IntermediateComment]?
    
    // MARK: - Init
    
    init(_ answer : Answer, contentWidth: CGFloat)
    {
        self.isAccepted = answer.isAccepted

        self.answerId = answer.answerId
        
        if let comments = answer.comments {
            self.comments = [IntermediateComment]()
            for comment in comments {
                self.comments!.append(IntermediateComment(comment, contentWidth: contentWidth))
            }
        }
        
        super.init(shallowUser: answer.owner, score: answer.score, creationDate: answer.creationDate, body: answer.body, contentWidth: contentWidth)
    }
    
    init(_ answer : AnswerMO, contentWidth: CGFloat)
    {
        self.isAccepted = answer.isAccepted
        
        self.answerId = Int(answer.answerId)
        
        if let comments = answer.comments?.allObjects as? [CommentMO] {
            self.comments = [IntermediateComment]()
            for comment in comments {
                self.comments!.append(IntermediateComment(comment, contentWidth: contentWidth))
            }
        }
        
        super.init(shallowUser: answer.owner, score: Int(answer.score), creationDate: Int(answer.creationDate), body: answer.body ?? "", contentWidth: contentWidth)
    }
}
