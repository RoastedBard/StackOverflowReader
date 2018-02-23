//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import CoreData

class QuestionView: UITableViewHeaderFooterView
{
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionScoreLabel: UILabel!  // Common
    @IBOutlet weak var questionBodyTextView: UITextView!  // Common
    
    @IBOutlet weak var questionDateLabel: UILabel!
    @IBOutlet weak var questionAuthorNameButton: UIButton!  // Common
    @IBOutlet weak var questionAuthorProfileImage: UIImageView!
    @IBOutlet weak var questionClosedReasonLabel: UILabel!
    
    @IBOutlet weak var showCommentsButton: UIButton!
    @IBOutlet weak var saveQuestionButton: UIButton!
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    
    var ownerUserId : Int = -1
    var question: IntermediateQuestion?
    
    func initializeQuestionView(_ question : IntermediateQuestion, _ profilePicture : UIImage?, isDataFromStorage : Bool)
    {
        if let reason = question.closedReason {
            questionClosedReasonLabel.text = "CLOSED AS: \(reason.string)"
        }
        
        questionTitleLabel.text = question.title?.string ?? "NOT_SPECIFIED"
        
        questionBodyTextView.attributedText = question.body
        
        questionAuthorNameButton.setTitle(question.owner?.displayName?.string, for: .normal)
        
        questionScoreLabel.text = "\(question.score)"
        
        if let picture = profilePicture {
            questionAuthorProfileImage.image = picture
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        questionDateLabel.text = "\(dateFormatter.string(from: question.creationDate))"
        
        showCommentsButton.isHidden = (question.comments != nil) ? false : true
        
        self.ownerUserId = question.owner?.userId ?? -1
        self.question = question
        
        if isDataFromStorage == true {
            saveQuestionButton.isHidden = true
        }
    }
    
    // MARK : Core Data
    @IBAction func saveQuestionButtonPressed(_ sender: UIButton)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.dataController.managedObjectContext
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = managedContext
        
        privateMOC.perform {
            
            guard let question = self.question else {
                return
            }
            
            // Full question
            let fullQuestionEntity = NSEntityDescription.entity(forEntityName: "SavedQuestion", in: privateMOC)!
            
            guard let fullQuestion = NSManagedObject(entity: fullQuestionEntity, insertInto: privateMOC) as? SavedQuestionMO else {
                print("Failed to create SavedQuestionMO in SaveQuestion")
                return
            }
            
            fullQuestion.questionId = Int32(question.questionId)
            
            if let closedDate = question.closedDate {
                fullQuestion.closedDate = Int32(closedDate)
            }
            
            fullQuestion.closedReason = question.closedReason?.string
            fullQuestion.isAnswered = question.isAnswered
            
            // Brief question
            self.createBriefQuestion(to: fullQuestion, source: question, context: privateMOC)
            
            // Question comments
            if let comments = question.comments {
                for comment in comments {
                    self.addComment(to: fullQuestion, source: comment, context: privateMOC)
                }
            }
            
            // Answers
            if let answers = question.answers {
                for answer in answers {
                    self.addAnswer(to: fullQuestion, source: answer, context: privateMOC)
                }
            }
            
            // Save everything
            do{
                try privateMOC.save()
                
                managedContext.performAndWait {
                    appDelegate.dataController.saveContext()
                }
            } catch {
                print("Failed to save context: \(error)")
                exit(0)
            }
        }
    }
    
    fileprivate func createBriefQuestion(to fullQuestion: SavedQuestionMO, source question : IntermediateQuestion, context : NSManagedObjectContext)
    {
        let briefQuestionEntity = NSEntityDescription.entity(forEntityName: "BriefQuestion", in: context)!
        
        guard let briefQuestionMO = NSManagedObject(entity: briefQuestionEntity, insertInto: context) as? BriefQuestionMO else {
            print("Failed to create BriefQuestionMO in SaveQuestion")
            return
        }
        
        if let acceptedAnswerId = question.acceptedAnswerId {
            briefQuestionMO.acceptedAnswerId = Int32(acceptedAnswerId)
        }
        
        briefQuestionMO.questionId = Int32(question.questionId)
        
        if question.closedReason != nil {
            briefQuestionMO.isClosed = true
        } else {
            briefQuestionMO.isClosed = false
        }
        
        briefQuestionMO.title = question.title?.string
        briefQuestionMO.dateSaved = Date()
        
        fillCommonData(commonDataMO: briefQuestionMO, intermediateCommonData: question, context: context)
        
        briefQuestionMO.detailQuestion = fullQuestion
        fullQuestion.brief = briefQuestionMO
    }
    
    fileprivate func addAnswer(to question: SavedQuestionMO, source answer : IntermediateAnswer, context : NSManagedObjectContext)
    {
        let answerEntity = NSEntityDescription.entity(forEntityName: "Answer", in: context)!
        
        guard let answerMO = NSManagedObject(entity: answerEntity, insertInto: context) as? AnswerMO else {
            print("Failed to create AnswerMO in SaveQuestion")
            return
        }
        
        answerMO.answerId = Int32(answer.answerId)
        answerMO.isAccepted = answer.isAccepted
        
        fillCommonData(commonDataMO: answerMO, intermediateCommonData: answer, context: context)
        
        answerMO.question = question
        
        // Answer comments
        if let comments = answer.comments {
            for comment in comments {
                self.addComment(to: answerMO, source: comment, context: context)
            }
        }
    }
    
    fileprivate func addComment(to object: NSManagedObject, source comment : IntermediateComment, context : NSManagedObjectContext)
    {
        // Comment entity and managed object
        let commentEntity = NSEntityDescription.entity(forEntityName: "Comment", in: context)!
        
        guard let commentMO = NSManagedObject(entity: commentEntity, insertInto: context) as? CommentMO else {
            print("Failed to create CommentMO in SaveQuestion")
            return
        }
        
        commentMO.commentId = Int32(comment.commentId)
        commentMO.postId = Int32(comment.postId)
        
        fillCommonData(commonDataMO: commentMO, intermediateCommonData: comment, context: context)

        // Add comment to the array of comments
        object.mutableSetValue(forKey: "comments").add(commentMO)
    }
    
    fileprivate func addOwner(to object: CommonModelDataMO, source answerCommentOrQuestion: IntermediateCommon, context: NSManagedObjectContext)
    {
        if let owner = answerCommentOrQuestion.owner {
            let ownerEntity = NSEntityDescription.entity(forEntityName: "ShallowUser", in: context)!
            
            guard let ownerDataMO = NSManagedObject(entity: ownerEntity, insertInto: context) as? ShallowUserMO else {
                print("Failed to create ShallowUserMO in SaveQuestion")
                return
            }
            
            ownerDataMO.displayName = owner.displayName?.string
            
            if let userId = owner.userId {
                ownerDataMO.userId = Int32(userId)
            }
            ownerDataMO.profileImage = owner.profileImage
            
            object.owner = ownerDataMO
        }
    }
    
    fileprivate func fillCommonData(commonDataMO : CommonModelDataMO, intermediateCommonData : IntermediateCommon, context: NSManagedObjectContext)
    {
        commonDataMO.body = intermediateCommonData.bodyOriginal
        commonDataMO.creationDate = Int32(intermediateCommonData.creationDate.timeIntervalSince1970)
        commonDataMO.score = Int32(intermediateCommonData.score)
        
        addOwner(to: commonDataMO, source: intermediateCommonData, context: context)
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
