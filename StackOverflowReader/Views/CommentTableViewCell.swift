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
    
    var owner : ShallowUser?
    
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

    func initializeCommentCell(_ comment: Comment, _ attributedData : CommonAttributedData)
    {
        if let owner = comment.owner {
            self.owner = owner
        }

        commentBodyTextView.attributedText = attributedData.attributedBodyString

        commentAuthorNameButton.setTitle(attributedData.attributedAuthorNameString?.string ?? "NOT_SPECIFIED", for: .normal)

        commentScoreLabel.text = "\(comment.score)"
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: owner?.userId ?? -1)
    }
}
