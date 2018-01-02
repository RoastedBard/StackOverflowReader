//
//  AnswerTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/2/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var commentsStackView: UIStackView!
    @IBOutlet weak var answerScoreLabel: UILabel!
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!
    @IBOutlet weak var answerAuthorNameLabel: UILabel!
    @IBOutlet weak var answerDateLabel: UILabel!
    
    var isInitialized : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCell(answer: Answer) {
        if isInitialized {
            return
        }
        
        answerScoreLabel.text = "\((answer.votes)!)"
        answerBodyTextView.text = answer.body
        
        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        }
        
        answerAuthorNameLabel.text = answer.author?.userName
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "en_US")
        print(dateFormatter.string(from: answer.date!))
        answerDateLabel.text = dateFormatter.string(from: answer.date!)
        
        if let comments = answer.comments{
            for comment in comments {
                addComment(comment: comment)
            }
        }
        
        isInitialized = true
    }
    
    func addComment(comment : Comment){
        let commentView = UINib(nibName: "CommentView", bundle: nil).instantiate(withOwner: self, options: nil).first as! CommentView
        
        commentView.initCommentView(comment : comment)
        
        commentsStackView.addArrangedSubview(commentView)
    }
}
