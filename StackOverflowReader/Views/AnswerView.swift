//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class AnswerView: UITableViewHeaderFooterView
{
    // MARK: - UI Elements
    
    @IBOutlet weak var answerScoreLabel: UILabelWithBorderAndInsets!
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!
    @IBOutlet weak var authorAndDateView: AuthorAndDateInfoView!
    @IBOutlet weak var showCommentsButton: UIButton!
    
    // MARK: - Delegates
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol?
    
    // MARK: - Properties
    
    var ownerUserId : Int = -1
    
    // MARK: - Lifecycle
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
    }
    
    // MARK: - Methods
    
    func initializeAnswerView(with answer : IntermediateAnswer, _ profilePicture : UIImage?)
    {
        answerScoreLabel.text = "\(answer.score)"
        
        answerBodyTextView.attributedText = answer.body
        
        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        authorAndDateView.fillViewWithData(date: dateFormatter.string(from: answer.creationDate), authorName: answer.owner?.displayName?.string, authorImageURL: answer.owner?.profileImage, userId: answer.owner?.userId)
        
        showCommentsButton.isHidden = (answer.comments != nil) ? false : true
        
        self.ownerUserId = answer.owner?.userId ?? -1
    }
}
