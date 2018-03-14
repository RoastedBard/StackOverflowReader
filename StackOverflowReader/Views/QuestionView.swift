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
        if isDataFromStorage == true || AuthorizationManager.isAuthorized == false {
            saveQuestionButton.isHidden = true
        }
        
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
    }
    
    // MARK : Core Data
    @IBAction func saveQuestionButtonPressed(_ sender: UIButton)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.dataController.saveQuestion(question: self.question)
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
