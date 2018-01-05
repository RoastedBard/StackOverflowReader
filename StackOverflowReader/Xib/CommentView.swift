//
//  CommentView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/29/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit

class CommentView: UIView {

    @IBOutlet weak var commentBodyTextView: UITextView!
    @IBOutlet weak var commentScoreLabel: UILabel!
    @IBOutlet weak var commentAuthorLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func initCommentView(comment : Comment){
        commentScoreLabel.text = "\(comment.score)"
        commentBodyTextView.text = comment.body
        
        if let owner = comment.owner {
            commentAuthorLabel.text = owner.displayName
        }
    }
}
