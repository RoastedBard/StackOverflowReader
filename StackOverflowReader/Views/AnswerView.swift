//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class AnswerView: UIView {

    @IBOutlet weak var answerScoreLabel: UILabel!
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!
    @IBOutlet weak var answerAuthorNameLabel: UILabel!
    @IBOutlet weak var answerDateLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializeAnswerView(_ answer : Answer) {
        answerScoreLabel.text = "\(answer.score)"
        answerBodyTextView.text = answer.body
        
        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        if let owner = answer.owner {
            answerAuthorNameLabel.text = owner.displayName
        }
        
        answerDateLabel.text = "\(answer.creationDate)"
    }

}
