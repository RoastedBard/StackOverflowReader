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
            let briefQuestionEntity = NSEntityDescription.entity(forEntityName: "BriefQuestion", in: privateMOC)!
            
            guard let briefQuestionMO = NSManagedObject(entity: briefQuestionEntity, insertInto: privateMOC) as? BriefQuestionMO else {
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
            briefQuestionMO.body = question.bodyOriginal
            briefQuestionMO.creationDate = Int32(question.creationDate.timeIntervalSince1970)
            briefQuestionMO.score = Int32(question.score)
            briefQuestionMO.dateSaved = Date()
            
            let ownerEntity = NSEntityDescription.entity(forEntityName: "ShallowUser", in: privateMOC)!
            
            guard let ownerDataMO = NSManagedObject(entity: ownerEntity, insertInto: privateMOC) as? ShallowUserMO else {
                print("Failed to create ShallowUserMO in SaveQuestion")
                return
            }
            
            ownerDataMO.displayName = question.owner?.displayName?.string
            
            if let userId = question.owner?.userId {
                ownerDataMO.userId = Int32(userId)
            }
            
            ownerDataMO.profileImage = question.owner?.profileImage
            
            briefQuestionMO.owner = ownerDataMO
            briefQuestionMO.detailQuestion = fullQuestion
            
            fullQuestion.brief = briefQuestionMO
            
            // Question comments
            if let comments = question.comments {
                for comment in comments {
                    
                    // Comment entity and managed object
                    let commentEntity = NSEntityDescription.entity(forEntityName: "Comment", in: privateMOC)!

                    guard let commentMO = NSManagedObject(entity: commentEntity, insertInto: privateMOC) as? CommentMO else {
                        print("Failed to create CommentMO in SaveQuestion")
                        return
                    }

                    commentMO.commentId = Int32(comment.commentId)
                    commentMO.postId = Int32(comment.postId)
                    commentMO.body = comment.bodyOriginal
                    commentMO.creationDate = Int32(comment.creationDate.timeIntervalSince1970)
                    commentMO.score = Int32(comment.score)

                    // Comment owner
                    if let owner = comment.owner {
                        let qOwnerEntity = NSEntityDescription.entity(forEntityName: "ShallowUser", in: privateMOC)!

                        guard let qOwnerDataMO = NSManagedObject(entity: qOwnerEntity, insertInto: privateMOC) as? ShallowUserMO else {
                            print("Failed to create ShallowUserMO in SaveQuestion")
                            return
                        }

                        qOwnerDataMO.displayName = owner.displayName?.string
                        if let userId = owner.userId {
                            qOwnerDataMO.userId = Int32(userId)
                        }
                        qOwnerDataMO.profileImage = owner.profileImage

                        commentMO.owner = qOwnerDataMO
                    }
                    
                    // Add comment to the array of comments
                    fullQuestion.mutableSetValue(forKey: "comments").add(commentMO)
                }
            }
            
            
            
            // Answers
            if let answers = question.answers {
                for answer in answers {
                    let answerEntity = NSEntityDescription.entity(forEntityName: "Answer", in: privateMOC)!
                    
                    guard let answerMO = NSManagedObject(entity: answerEntity, insertInto: privateMOC) as? AnswerMO else {
                        print("Failed to create AnswerMO in SaveQuestion")
                        return
                    }
                    
                    answerMO.answerId = Int32(answer.answerId)
                    answerMO.isAccepted = answer.isAccepted
                    answerMO.body = answer.bodyOriginal
                    answerMO.creationDate = Int32(answer.creationDate.timeIntervalSince1970)
                    answerMO.score = Int32(answer.score)
                    
                    if let owner = answer.owner{
                        // Answer owner
                        let aOwnerEntity = NSEntityDescription.entity(forEntityName: "ShallowUser", in: privateMOC)!
                        
                        guard let aOwnerDataMO = NSManagedObject(entity: aOwnerEntity, insertInto: privateMOC) as? ShallowUserMO else {
                            print("Failed to create ShallowUserMO in SaveQuestion")
                            return
                        }
                        
                        aOwnerDataMO.displayName = owner.displayName?.string
                        if let userId = owner.userId {
                            aOwnerDataMO.userId = Int32(userId)
                        }
                        aOwnerDataMO.profileImage = owner.profileImage
                        
                        answerMO.owner = aOwnerDataMO
                    }
                    
                    answerMO.question = fullQuestion
                    
                    // Answer comments
                    if let comments = answer.comments {
                        for comment in comments {
                            // Comment entity and managed object
                            let commentEntity = NSEntityDescription.entity(forEntityName: "Comment", in: privateMOC)!
                            
                            guard let commentMO = NSManagedObject(entity: commentEntity, insertInto: privateMOC) as? CommentMO else {
                                print("Failed to create CommentMO in SaveQuestion")
                                return
                            }
                            
                            commentMO.commentId = Int32(comment.commentId)
                            commentMO.postId = Int32(comment.postId)
                            commentMO.body = comment.bodyOriginal
                            commentMO.creationDate = Int32(comment.creationDate.timeIntervalSince1970)
                            commentMO.score = Int32(comment.score)
                            
                            // Comment owner
                            if let owner = comment.owner {
                                let qOwnerEntity = NSEntityDescription.entity(forEntityName: "ShallowUser", in: privateMOC)!
                                
                                guard let qOwnerDataMO = NSManagedObject(entity: qOwnerEntity, insertInto: privateMOC) as? ShallowUserMO else {
                                    print("Failed to create ShallowUserMO in SaveQuestion")
                                    return
                                }
                                
                                qOwnerDataMO.displayName = owner.displayName?.string
                                if let userId = owner.userId {
                                    qOwnerDataMO.userId = Int32(userId)
                                }
                                commentMO.owner = qOwnerDataMO
                            }
                            
                            // Add comment to the array of comments
                            answerMO.mutableSetValue(forKey: "comments").add(commentMO)
                        }
                    }
                }
            }
            
            // Save everything
            do{
                try privateMOC.save()
                
                managedContext.performAndWait {
                    appDelegate.dataController.saveContext()
                }
            } catch {
                print("Failure to save context: \(error)")
                exit(0)
            }
        }
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
