//
//  QuestionTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/2/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class QuestionTableViewCell: UITableViewCell{

    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionScoreLabel: UILabel!
    @IBOutlet weak var questionBodyTextView: UITextView!
    @IBOutlet weak var questionAuthorNameLabel: UILabel!
    @IBOutlet weak var questionDateLabel: UILabel!
    
    @IBOutlet weak var commentsStackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(question: Question) {
        
        questionTitleLabel.text = question.title
        questionScoreLabel.text = "\(question.score)"
        questionBodyTextView.text = question.body
        
        if let owner = question.owner {
            questionAuthorNameLabel.text = owner.displayName
        }
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        questionDateLabel.text = "\(question.creationDate)"
        
        if let comments = question.comments{
            for comment in comments {
                addComment(comment: comment)
            }
        }
    }
    
    func addComment(comment : Comment){
//        if comment.isCommentInitialized {
//            return
//        }
        
        let commentView = UINib(nibName: "CommentView", bundle: nil).instantiate(withOwner: self, options: nil).first as! CommentView
        
        commentView.initCommentView(comment : comment)
        
        commentsStackView.addArrangedSubview(commentView)
        
        //comment.isCommentInitialized = true
    }
}
