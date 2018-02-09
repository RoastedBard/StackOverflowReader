//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
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
    
    var owner : ShallowUser?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initializeAnswerView(_ answer : Answer, screenWidth width : CGFloat, attributedData : CommonAttributedData, _ profilePicture : UIImage?)
    {
        answerScoreLabel.text = "\(answer.score)"
        
        answerBodyTextView.attributedText = attributedData.attributedBodyString
        
        answerAuthorNameButton.setTitle(attributedData.attributedAuthorNameString?.string, for: .normal)

        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        if let picture = profilePicture {
            answerAuthorProfileImage.image = picture
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(answer.creationDate))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        answerDateLabel.text = "\(dateFormatter.string(from: date))"
        
        if let comments = answer.comments {
            if answer.isCommentsCollapsed == true {
                showCommentsButton.setTitle("Show comments (\(comments.count))", for: .normal)
            } else {
                showCommentsButton.setTitle("Hide comments (not supported yet)", for: .normal)
            }
        }
        
        showCommentsButton.isHidden = (answer.comments != nil) ? false : true
    }

    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: owner?.userId ?? -1)
    }
}
