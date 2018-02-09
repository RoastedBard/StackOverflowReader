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
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol? // Common
    
    var userId = 0
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
    
    func initCell(question : BriefQuestion, attributedData : CommonAttributedData)
    {
        titleLabel.text = attributedData.attributedBodyString?.string
        authorNameButton.setTitle(attributedData.attributedAuthorNameString?.string, for: .normal)
        
        scoreLabel.text = "\(question.score)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let date = Date(timeIntervalSince1970: TimeInterval(question.creationDate))
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateLabel.text = "\(dateFormatter.string(from: date))"
        
        self.questionId = question.questionId
        self.userId = question.owner?.userId ?? -1
    }
    
    @IBAction func authorNameButtonPressed(_ sender: UIButton) {
        authorNamePressedDelegate?.authorNamePressed(userId: userId)
    }
}
