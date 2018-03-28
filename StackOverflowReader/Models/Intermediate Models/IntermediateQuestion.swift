//
//  IntermediateQuestion.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

class IntermediateQuestion : IntermediateCommon
{
    // MARK: - Properties
    
    var tags : [String]?
    var comments : [IntermediateComment]?
    var answers : [IntermediateAnswer]?
    var acceptedAnswerId : Int?
    var closedDate : Int?
    var closedReason : NSAttributedString?
    var isAnswered : Bool = false
    var title : NSAttributedString?
    var questionId : Int
    
    // MARK: - Init
    
    init(question : Question, contentWidth : CGFloat)
    {
        self.questionId = question.questionId
        
        self.isAnswered = question.isAnswered
        
        if let title = question.title?.htmlAttributedString {
            self.title = title
        }
        
        if let tags = question.tags {
            self.tags = tags
        }
        
        if let acceptedAnswerId = question.acceptedAnswerId {
            self.acceptedAnswerId = acceptedAnswerId
        }
        
        if let closedDate = question.closedDate {
            self.closedDate = closedDate
        }
        
        if let closedReason = question.closedReason?.htmlAttributedString {
            self.closedReason = closedReason
        }
        
        if let comments = question.comments{
            self.comments = [IntermediateComment]()
            
            for comment in comments {
                self.comments!.append(IntermediateComment(comment, contentWidth: contentWidth))
            }
        }
        
        if let answers = question.answers{
            self.answers = [IntermediateAnswer]()
            
            for answer in answers {
                self.answers!.append(IntermediateAnswer(answer, contentWidth: contentWidth))
            }
        }
        
        super.init(shallowUser: question.owner, score: question.score, creationDate: question.creationDate, body: question.body, contentWidth: contentWidth)
    }
    
    init(question : SavedQuestionMO, contentWidth : CGFloat)
    {
        self.questionId = Int(question.questionId)
        
        self.isAnswered = question.isAnswered
        
        if let title = question.brief?.title?.htmlAttributedString {
            self.title = title
        }
        
        self.closedDate = Int(question.closedDate)
        
        if let closedReason = question.closedReason?.htmlAttributedString {
            self.closedReason = closedReason
        }
        
        if let comments = question.comments?.allObjects as? [CommentMO]{
            self.comments = [IntermediateComment]()
            
            for comment in comments {
                self.comments!.append(IntermediateComment(comment, contentWidth: contentWidth))
            }
        }
        
        if let answers = question.answers?.allObjects as? [AnswerMO]{
            self.answers = [IntermediateAnswer]()
            
            for answer in answers {
                self.answers!.append(IntermediateAnswer(answer, contentWidth: contentWidth))
            }
        }
        
        guard let briefQuestion = question.brief else {
            print("Failed to init question form managed object")
            exit(0)
        }
        
        super.init(shallowUser: briefQuestion.owner, score: Int(briefQuestion.score), creationDate: Int(briefQuestion.creationDate), body: briefQuestion.body ?? "", contentWidth: contentWidth)
    }
}
