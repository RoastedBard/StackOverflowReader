//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        setup()
    }
    
    func setup()
    {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}

class AnswerView: UITableViewHeaderFooterView
{
    @IBOutlet weak var answerScoreLabel: UILabel!  // Common
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!  // Common
    
    @IBOutlet weak var answerAuthorNameButton: UIButton!  // Common
    @IBOutlet weak var answerDateLabel: UILabel!
    @IBOutlet weak var answerAuthorProfileImage: UIImageView!
    
    @IBOutlet weak var showCommentsButton: UIButton!
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    
    var ownerUserId : Int = -1 // Common
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
    }
    
    func initializeAnswerView(_ answer : IntermediateAnswer, _ profilePicture : UIImage?)
    {
        answerScoreLabel.text = "\(answer.score)"
        
        answerBodyTextView.attributedText = answer.body
        
        answerAuthorNameButton.setTitle(answer.owner?.displayName?.string, for: .normal)

        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        if let picture = profilePicture {
            answerAuthorProfileImage.image = picture
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        answerDateLabel.text = "\(dateFormatter.string(from: answer.creationDate))"
        
        showCommentsButton.isHidden = (answer.comments != nil) ? false : true
        
        self.ownerUserId = answer.owner?.userId ?? -1
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
