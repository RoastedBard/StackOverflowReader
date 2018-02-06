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
    @IBOutlet weak var commentBodyTextView: UITextView!
    @IBOutlet weak var commentScoreLabel: UILabel!
    @IBOutlet weak var commentAuthorNameButton: UIButton!
    
    var delegate : AuthorNamePressedProtocol?
    
    var owner : ShallowUser?
    
    var attributedCommentBodyString : NSAttributedString?
    var attributedCommentAuthorString : NSAttributedString?
    
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
    
//    func initializeCommentCell(_ comment: Comment)
//    {
//        if let owner = comment.owner {
//            self.owner = owner
//        }
//
//        attributedCommentBodyString = comment.body.htmlAttributedString
//        commentBodyTextView.attributedText = attributedCommentBodyString
//
//        if let owner = comment.owner {
//            attributedCommentAuthorString = owner.displayName!.htmlAttributedString
//            commentAuthorNameButton.setTitle(attributedCommentAuthorString!.string, for: .normal)
//        }
//
//        commentScoreLabel.text = "\(comment.score)"
//    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        delegate?.authorNamePressed(userId: owner?.userId ?? -1)
    }
}
