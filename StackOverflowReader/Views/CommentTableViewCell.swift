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
    
    var owner : User?
    
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
    
    func initializeCommentCell(_ comment: Comment)
    {
        commentBodyTextView.text = comment.body
        commentScoreLabel.text = "\(comment.score)"
        
        if let owner = comment.owner {
            self.owner = owner
            commentAuthorNameButton.setTitle(owner.displayName, for: .normal)
        }
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        delegate?.authorNamePressed(owner)
    }
}
