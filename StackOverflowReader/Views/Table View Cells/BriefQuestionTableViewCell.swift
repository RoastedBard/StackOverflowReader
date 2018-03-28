//
//  BriefQuestionTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/4/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class BriefQuestionTableViewCell: UITableViewCell
{
    // MARK: - UI Elements
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorNameButton: UIButton!
    @IBOutlet weak var tagCollectionView: UIView!
    @IBOutlet weak var tagCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptedOrClosedImageView: UIImageView!
    
    // MARK: - Delegates
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol?
    
    // MARK: - Properties
    
    var ownerUserId = -1
    var questionId = 0
    
    // MARK: - Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Methods
    
    func initCell(question : BriefQuestionMO)
    {
        let briefQuestion = IntermediateBriefQuestion(question)
        
        initCell(question: briefQuestion)
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
            acceptedOrClosedImageView.image = #imageLiteral(resourceName: "icons8-checked-50")
        } else if question.isClosed == true {
            acceptedOrClosedImageView.image = #imageLiteral(resourceName: "icons8-cancel-40")
        } else {
            acceptedOrClosedImageView.image = nil
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
            let tagView = UILabelWithBorderAndInsets(frame: CGRect(x: nextOrigin.x, y: nextOrigin.y, width: 0, height: 0))
            
            tagView.isUserInteractionEnabled = true
            
            tagView.text = tag
            
            tagView.font = UIFont(name: "Helvetica", size: 14)
            
            tagView.layer.masksToBounds = true;
            tagView.borderWidth = 1
            tagView.cornerRadius = 10
            tagView.borderColor = #colorLiteral(red: 0.8791649938, green: 0.923817575, blue: 0.9553330541, alpha: 1)
            tagView.backgroundColor = #colorLiteral(red: 0.8791649938, green: 0.923817575, blue: 0.9553330541, alpha: 1)
            tagView.textColor = #colorLiteral(red: 0.2233205736, green: 0.4514970183, blue: 0.6146772504, alpha: 1)
            tagView.leftTextInset = 5.0
            tagView.rightTextInset = 5.0
            tagView.topTextInset = 1.0
            tagView.bottomTextInset = 1.0
            
            tagView.sizeToFit()
            tagView.frame.size.height = buttonHeight
            
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
    
    //MARK: - Actions
    
    @IBAction func authorNameButtonPressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
