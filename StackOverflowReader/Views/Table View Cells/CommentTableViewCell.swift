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
    // MARK: - UI Elements
    
    @IBOutlet weak var commentBodyTextView: UITextView!
    @IBOutlet weak var commentScoreLabel: UILabelWithBorderAndInsets!
    @IBOutlet weak var commentAuthorNameButton: UIButton!
    
    // MARK: - Delegates
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol?
    
    // MARK: - Properties
    
    var ownerUserId : Int = -1
    
    // MARK: - Lifecycle
    
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

    // MARK: - Methods
    
    func initializeCommentCell(_ comment: IntermediateComment)
    {
        self.ownerUserId = comment.owner?.userId ?? -1
        
        commentBodyTextView.attributedText = comment.body

        commentAuthorNameButton.setTitle(comment.owner?.displayName?.string ?? "NOT_SPECIFIED", for: .normal)

        commentScoreLabel.text = "\(comment.score)"
    }
    
    // MARK: - Actions
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
