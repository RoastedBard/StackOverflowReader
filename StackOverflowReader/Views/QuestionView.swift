//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class QuestionView: UIView
{
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionScoreLabel: UILabel!
    @IBOutlet weak var questionBodyTextView: UITextView!
    
    @IBOutlet weak var questionDateLabel: UILabel!
    @IBOutlet weak var questionAuthorNameButton: UIButton!
    @IBOutlet weak var questionAuthorProfileImage: UIImageView!
    
    var delegate : AuthorNamePressedProtocol?
    
    var owner : ShallowUser?
    
    override init(frame: CGRect)
    {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    func initializeQuestionView(_ question : Question)
    {
        questionTitleLabel.text = question.title
        questionScoreLabel.text = "\(question.score)"
        questionBodyTextView.text = question.body
        
        if let owner = question.owner {
            questionAuthorNameButton.setTitle(owner.displayName, for: .normal)
            
            if let userImageLink = owner.profileImage {
                if let url = URL(string: userImageLink) {
                    LinkToImageViewHelper.downloadImage(from: url, to: questionAuthorProfileImage)
                }
            }
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(question.creationDate))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        questionDateLabel.text = "\(dateFormatter.string(from: date))"
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        delegate?.authorNamePressed(owner)
    }
}
