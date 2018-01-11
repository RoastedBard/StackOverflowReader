//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class QuestionView: UIView {

    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionScoreLabel: UILabel!
    @IBOutlet weak var questionBodyTextView: UITextView!
    
    @IBOutlet weak var questionDateLabel: UILabel!
    @IBOutlet weak var questionAuthorNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initializeQuestionView(_ question : Question){
        questionTitleLabel.text = question.title
        questionScoreLabel.text = "\(question.score)"
        questionBodyTextView.text = question.body
        
        if let owner = question.owner {
            questionAuthorNameLabel.text = owner.displayName
        }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        questionDateLabel.text = "\(question.creationDate)"
    }

}
