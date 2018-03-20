//
//  SOPostCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/4/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class SOPostCell: UITableViewCell
{
    @IBOutlet weak var scoreLabel: UILabel!  // Common
    @IBOutlet weak var titleLabel: UILabel!  // Common
    @IBOutlet weak var dateLabel: UILabel!  // Common
    
    @IBOutlet weak var authorNameButton: UIButton!
    
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var tagCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    
    var ownerUserId = -1
    var questionId = 0
    
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
    
    func initCell(question : IntermediateBriefQuestion)
    {
        titleLabel.text = question.title?.string
        authorNameButton.setTitle(question.owner?.displayName?.string, for: .normal)
        
        scoreLabel.text = "\(question.score)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateLabel.text = "\(dateFormatter.string(from: question.creationDate))"
        
        if question.acceptedAnswerId != nil {
            self.backgroundColor = #colorLiteral(red: 0.7333333333, green: 0.9960784314, blue: 0.7764705882, alpha: 1)
        } else if question.isClosed == true {
            self.backgroundColor = #colorLiteral(red: 0.8707411024, green: 0.5153266059, blue: 0.6025402082, alpha: 1)
        } else {
            self.backgroundColor = .white
        }
        
        self.questionId = question.questionId
        self.ownerUserId = question.owner?.userId ?? -1
        
        if let tags = question.tags {
            createTags(tags: tags)
        }
    }
    
    func createTags(tags : [String])
    {
        tagCollectionView.subviews.forEach({ $0.removeFromSuperview() })
        
        tagCollectionViewHeightConstraint.constant = 24
        
        let buttonHeight : CGFloat = 24
        let horizontalSpacing : CGFloat = 8
        let verticalSpacing : CGFloat = 8
        
        var nextOrigin : CGPoint = CGPoint.zero
        
        for tag in tags {
            let tagView = UILabel(frame: CGRect(x: nextOrigin.x, y: nextOrigin.y, width: 0, height: 0))
            tagView.text = tag == tags.last ? tag : "\(tag),"
            tagView.sizeToFit()
            tagView.frame.size.height = buttonHeight
            tagView.textColor = .black

            if (nextOrigin.x + tagView.frame.width + horizontalSpacing) > tagCollectionView.frame.width {
                nextOrigin.x = 0.0
                nextOrigin.y += buttonHeight + verticalSpacing
                
                tagCollectionViewHeightConstraint.constant += buttonHeight + verticalSpacing
                
                tagView.frame.origin = nextOrigin
            }
            
            tagCollectionView.addSubview(tagView)
            
            nextOrigin.x = tagView.frame.maxX + horizontalSpacing
        }
    }
    
    @IBAction func authorNameButtonPressed(_ sender: UIButton) {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
