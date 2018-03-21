//
//  DataController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/19/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class DataController: NSObject
{
    var managedObjectContext: NSManagedObjectContext
    
    init(completionClosure: @escaping () -> ())
    {
        guard let modelURL = Bundle.main.url(forResource: "StackOverflowReader", withExtension:"momd") else {
            print("Error loading model from bundle")
            exit(0)
        }
       
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            print("Error initializing mom from: \(modelURL)")
            exit(0)
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = psc
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                print("Unable to resolve document directory")
                exit(0)
            }
            
            let savedPostsStoreURL = docURL.appendingPathComponent("StackOverflowReader.sqlite")
    
            do {
                var options = [String:Any]()
                options[NSMigratePersistentStoresAutomaticallyOption] = true
                options[NSInferMappingModelAutomaticallyOption] = true
                
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: savedPostsStoreURL, options: options)
                
                DispatchQueue.main.sync(execute: completionClosure)
            } catch {
                print("Error migrating store: \(error)")
                exit(0)
            }
        }
    }
    
    func saveContext ()
    {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
                
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                exit(0)
            }
        }
    }
    
    // MARK: - History data operations
    
    func saveHistory()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.dataController.managedObjectContext
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = managedContext
        
        privateMOC.perform {
            
            // Logged  user
            var loggedUserMO : LoggedUserMO?
            
            if let authorizedUserId = AuthorizationManager.authorizedUser?.userId {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LoggedUser")
                fetchRequest.predicate = NSPredicate(format: "userId = %d", authorizedUserId)
                
                var results: [NSManagedObject] = []
                
                do {
                    results = try privateMOC.fetch(fetchRequest)
                }
                catch {
                    print("error executing fetch request: \(error)")
                }
                
                if results.count > 0 {
                    loggedUserMO = results[0] as? LoggedUserMO
                } else {
                    let loggedUserEntity = NSEntityDescription.entity(forEntityName: "LoggedUser", in: privateMOC)!
                    
                    loggedUserMO = NSManagedObject(entity: loggedUserEntity, insertInto: privateMOC) as? LoggedUserMO
                    
                    loggedUserMO?.userId = Int32(authorizedUserId)
                }
            }
            
            guard let loggedUser = loggedUserMO else {
                print("loggedUser not initialized")
                return
            }
            
            // SearchItem
            for searchHistoryItem in SearchHistoryManager.searchHistory {
                let searchHistoryItemEntity = NSEntityDescription.entity(forEntityName: "SearchItem", in: privateMOC)!
                
                guard let searchHistoryItemMO = NSManagedObject(entity: searchHistoryItemEntity, insertInto: privateMOC) as? SearchHistoryItemMO else {
                    print("Failed to create SearchHistoryItemMO in SaveHistory")
                    return
                }
                
                searchHistoryItemMO.searchQuery = searchHistoryItem.searchQuery
                
                // SearchItem.visitedQuestions
                for question in searchHistoryItem.visitedQuestions {
                    
                    let questionEntity = NSEntityDescription.entity(forEntityName: "BriefQuestion", in: privateMOC)!
                    
                    guard let questionMO = NSManagedObject(entity: questionEntity, insertInto: privateMOC) as? BriefQuestionMO else {
                        print("Failed to create BriefQuestionMO in SaveQuestion")
                        return
                    }
                    
                    if let acceptedAnswerId = question.acceptedAnswerId {
                        questionMO.acceptedAnswerId = Int32(acceptedAnswerId)
                    }
                    
                    questionMO.questionId = Int32(question.questionId)
                    
                    questionMO.title = question.title?.string
                    questionMO.dateSaved = Date()
                    
                    self.fillCommonData(commonDataMO: questionMO, intermediateCommonData: question, context: privateMOC)
                    
                    questionMO.searchHistoryItem = searchHistoryItemMO
                    searchHistoryItemMO.mutableSetValue(forKey: "questions").add(questionMO)
                }
                
                searchHistoryItemMO.loggedUser = loggedUser
                loggedUser.mutableSetValue(forKey: "history").add(searchHistoryItem)
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
    
    func deleteHistory()
    {
        
    }
    
    // MARK: - Question data operations
    
    func saveQuestion(question : IntermediateQuestion?)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.dataController.managedObjectContext
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMOC.parent = managedContext
        
        privateMOC.perform {
            
            guard let question = question else {
                return
            }
            
            // Logged  user
            var loggedUserMO : LoggedUserMO?
            
            if let authorizedUserId = AuthorizationManager.authorizedUser?.userId {
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LoggedUser")
                fetchRequest.predicate = NSPredicate(format: "userId = %d", authorizedUserId)
                
                var results: [NSManagedObject] = []
                
                do {
                    results = try privateMOC.fetch(fetchRequest)
                }
                catch {
                    print("error executing fetch request: \(error)")
                }
                
                if results.count > 0 {
                    loggedUserMO = results[0] as? LoggedUserMO
                } else {
                    let loggedUserEntity = NSEntityDescription.entity(forEntityName: "LoggedUser", in: privateMOC)!
                    
                    loggedUserMO = NSManagedObject(entity: loggedUserEntity, insertInto: privateMOC) as? LoggedUserMO
                    
                    loggedUserMO?.userId = Int32(authorizedUserId)
                }
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
            
            if loggedUserMO != nil {
                fullQuestion.loggedUser = loggedUserMO
                //loggedUserMO!.mutableSetValue(forKey: "savedQuestions").add(fullQuestion)
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
}
