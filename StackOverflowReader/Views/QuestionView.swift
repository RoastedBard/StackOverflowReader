//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

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
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    
    var owner : ShallowUser?
    
    func initializeQuestionView(_ question : Question, screenWidth width : CGFloat, attributedData : QuestionAttributedData, _ profilePicture : UIImage?){

        if let reason = question.closedReason {
            questionClosedReasonLabel.text = "CLOSED AS: \(reason)"
        }
        
        questionTitleLabel.text = attributedData.attributedQuestionTitle?.string ?? "NOT_SPECIFIED"
        
        questionBodyTextView.attributedText = attributedData.attributedBodyString
        
        questionAuthorNameButton.setTitle(attributedData.attributedAuthorNameString?.string, for: .normal)
        
        questionScoreLabel.text = "\(question.score)"
        
        if let picture = profilePicture {
            questionAuthorProfileImage.image = picture
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(question.creationDate))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        questionDateLabel.text = "\(dateFormatter.string(from: date))"
        
        if let comments = question.comments {
            if question.isCommentsCollapsed == true {
                showCommentsButton.setTitle("Show comments (\(comments.count))", for: .normal)
            } else {
                showCommentsButton.setTitle("Hide comments (not supported yet)", for: .normal)
            }
        }
        
        showCommentsButton.isHidden = (question.comments != nil) ? false : true
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: owner?.userId ?? -1)
    }
}
