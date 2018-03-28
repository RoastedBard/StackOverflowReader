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

class QuestionView: UITableViewHeaderFooterView
{
    // MARK: - UI Elements
    
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionScoreLabel: UILabelWithBorderAndInsets!
    @IBOutlet weak var questionBodyTextView: UITextView!
    @IBOutlet weak var authorAndDateView: AuthorAndDateInfoView!
    @IBOutlet weak var questionClosedReasonLabel: UILabel!
    @IBOutlet weak var showCommentsButton: UIButton!
    @IBOutlet weak var saveQuestionButton: UIButton!
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var tagCollectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Delegates
    
    var tagPressedDelegate : TagButtonPressedProtocol?
    
    // MARK: - Properties

    var ownerUserId : Int = -1
    var question: IntermediateQuestion?

    // MARK: - Methods
    
    func initializeQuestionView(with question : IntermediateQuestion, _ profilePicture : UIImage?, isDataFromStorage : Bool)
    {
        if isDataFromStorage == true || AuthorizationManager.isAuthorized == false {
            saveQuestionButton.isHidden = true
        }
        
        if let reason = question.closedReason {
            questionClosedReasonLabel.text = "CLOSED AS: \(reason.string)"
        } else if questionClosedReasonLabel != nil, questionClosedReasonLabel.isDescendant(of: self) {
            questionClosedReasonLabel.removeFromSuperview()
            questionTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        }
        
        questionTitleLabel.text = question.title?.string ?? "NOT_SPECIFIED"
        
        questionBodyTextView.attributedText = question.body
        
        questionScoreLabel.text = "\(question.score)"
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        authorAndDateView.fillViewWithData(date: dateFormatter.string(from: question.creationDate), authorName: question.owner?.displayName?.string, authorImageURL: question.owner?.profileImage, userId: question.owner?.userId)
        
        showCommentsButton.isHidden = (question.comments != nil) ? false : true
        
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
            let tap = UITapGestureRecognizer(target: self, action: #selector(tagButtonPressed))
            
            let tagView = UILabelWithBorderAndInsets(frame: CGRect(x: nextOrigin.x, y: nextOrigin.y, width: 0, height: 0))
            
            tagView.isUserInteractionEnabled = true
            tagView.addGestureRecognizer(tap)
            
            tagView.text = tag
            
            tagView.font = UIFont(name: "Helvetica", size: 14)
            
            tagView.layer.masksToBounds = true;
            tagView.borderWidth = 1
            tagView.cornerRadius = 10
            tagView.borderColor = #colorLiteral(red: 0.8791649938, green: 0.923817575, blue: 0.9553330541, alpha: 1)
            tagView.backgroundColor = #colorLiteral(red: 0.8791649938, green: 0.923817575, blue: 0.9553330541, alpha: 1)
            tagView.textColor = #colorLiteral(red: 0.2233205736, green: 0.4514970183, blue: 0.6146772504, alpha: 1)
            tagView.leftTextInset = 5.0
            tagView.rightTextInset = 5.0
            tagView.topTextInset = 1.0
            tagView.bottomTextInset = 1.0
            
            tagView.sizeToFit()
            tagView.frame.size.height = buttonHeight
            
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
    
    //MARK: - Actions
    
    @IBAction func saveQuestionButtonPressed(_ sender: UIButton)
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.dataController.saveQuestion(question: self.question)
    }
    
    @objc func tagButtonPressed(_ sender: UITapGestureRecognizer)
    {
        if let tappedLabel = sender.view as? UILabelWithBorderAndInsets {
            tagPressedDelegate?.tagButtonPressed(tagText: tappedLabel.text ?? "NOT_IDENTIFIED")
        }
    }
}
