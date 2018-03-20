//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import CoreData

// MARK: - Delegates

protocol TagButtonPressedProtocol
{
    func tagButtonPressed(tagText : String)
}

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
    
    // MARK: - Delegates
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    var tagPressedDelegate : TagButtonPressedProtocol?
    
    // Tags
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var tagCollectionViewHeightConstraint: NSLayoutConstraint!
    
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
        
        if let tags = question.tags {
            createTags(tags: tags)
        }
    }
    
    func createTags(tags : [String])
    {
        tagCollectionView.subviews.forEach({ $0.removeFromSuperview() })
        
        tagCollectionViewHeightConstraint.constant = 24
        
        let buttonHeight : CGFloat = 24
        let horizontalSpacing : CGFloat = 8
        let verticalSpacing : CGFloat = 8
        
        var nextOrigin : CGPoint = CGPoint.zero
        
        for tag in tags {
            let tagView = UIButton(frame: CGRect(x: nextOrigin.x, y: nextOrigin.y, width: 0, height: 0))
            tagView.setTitle(tag, for: .normal)
            tagView.sizeToFit()
            tagView.frame.size.height = buttonHeight
            tagView.setTitleColor(.black, for: .normal)
            tagView.backgroundColor = .cyan
            tagView.addTarget(self, action: #selector(tagButtonPressed), for: .touchUpInside)
            
            if (nextOrigin.x + tagView.frame.width + horizontalSpacing) > tagCollectionView.frame.width {
                nextOrigin.x = 0.0
                nextOrigin.y += buttonHeight + verticalSpacing
                
                tagCollectionViewHeightConstraint.constant += buttonHeight + verticalSpacing
                
                tagView.frame.origin = nextOrigin
            }
            
            tagCollectionView.addSubview(tagView)
            
            nextOrigin.x = tagView.frame.maxX + horizontalSpacing
        }
    }
    
    // MARK: - Core Data
    @IBAction func saveQuestionButtonPressed(_ sender: UIButton)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.dataController.saveQuestion(question: self.question)
    }
    
    //MARK: - Actions
    
    @objc func tagButtonPressed(sender: UIButton!)
    {
        tagPressedDelegate?.tagButtonPressed(tagText: sender.titleLabel?.text ?? "")
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
