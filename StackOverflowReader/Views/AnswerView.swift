//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class AnswerView: UIView
{
    @IBOutlet weak var answerScoreLabel: UILabel!
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!
    
    @IBOutlet weak var answerAuthorNameButton: UIButton!
    @IBOutlet weak var answerDateLabel: UILabel!
    @IBOutlet weak var answerAuthorProfileImage: UIImageView!
    
    var delegate : AuthorNamePressedProtocol?
    
    var owner : User?
    
    override init(frame: CGRect)
    {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func initializeAnswerView(_ answer : Answer)
    {
        answerScoreLabel.text = "\(answer.score)"
        answerBodyTextView.text = answer.body
        
        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        if let owner = answer.owner {
            answerAuthorNameButton.setTitle(owner.displayName, for: .normal)
            
            if let userImageLink = owner.profileImage {
                if let url = URL(string: userImageLink) {
                    LinkToImageViewHelper.downloadImage(from: url, to: answerAuthorProfileImage)
                }
            }
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(answer.creationDate))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        answerDateLabel.text = "\(dateFormatter.string(from: date))"
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        delegate?.authorNamePressed(owner)
    }
    
}
