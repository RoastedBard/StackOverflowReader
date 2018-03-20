//
//  CommentTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/2/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell
{
    @IBOutlet weak var commentBodyTextView: UITextView!  // Common
    @IBOutlet weak var commentScoreLabel: UILabel!  // Common
    @IBOutlet weak var commentAuthorNameButton: UIButton!  // Common
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    
    var ownerUserId : Int = -1
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initializeCommentCell(_ comment: IntermediateComment)
    {
        self.ownerUserId = comment.owner?.userId ?? -1
        
        commentBodyTextView.attributedText = comment.body

        commentAuthorNameButton.setTitle(comment.owner?.displayName?.string ?? "NOT_SPECIFIED", for: .normal)

        commentScoreLabel.text = "\(comment.score)"
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
