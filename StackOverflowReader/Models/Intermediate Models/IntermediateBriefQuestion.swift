//
//  IntermediateBriefQuestion.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class IntermediateBriefQuestion : IntermediateCommon
{
    var tags : [String]?
    var isAnswered : Bool
    var title : NSAttributedString?
    var questionId : Int
    var acceptedAnswerId : Int?
    var isClosed : Bool = false
    var dateSaved : Date = Date()
    
    init(_ briefQuestion : BriefQuestion)
    {
        if briefQuestion.closedReason != nil {
            isClosed = true
        }
        
        if let acceptedAnswerId = briefQuestion.acceptedAnswerId {
            self.acceptedAnswerId = acceptedAnswerId
        }
        
        self.questionId = briefQuestion.questionId
        
        self.isAnswered = briefQuestion.isAnswered
        
        if let title = briefQuestion.title.htmlAttributedString {
            self.title = title
        }
        
        self.tags = briefQuestion.tags
        
        super.init(shallowUser: briefQuestion.owner, score: briefQuestion.score, creationDate: briefQuestion.creationDate, body: "", contentWidth: 0)
    }
    
    init(_ briefQuestion : BriefQuestionMO)
    {
        guard let detailQuestion = briefQuestion.detailQuestion else{
            print("Unable to get detailQuestion")
            exit(0)
        }
        
        self.isClosed = briefQuestion.isClosed
        
        if briefQuestion.acceptedAnswerId != 0 {
            self.acceptedAnswerId = Int(briefQuestion.acceptedAnswerId)
        }
        
        self.isAnswered = detailQuestion.isAnswered
        
        if let title = briefQuestion.title?.htmlAttributedString {
            self.title = title
        }
        
        self.questionId = Int(briefQuestion.questionId)
        
        if let date = briefQuestion.dateSaved {
            self.dateSaved = date
        }
        
        super.init(shallowUser: briefQuestion.owner, score: Int(briefQuestion.score), creationDate: Int(briefQuestion.creationDate), body: "", contentWidth: 0)
    }
}
