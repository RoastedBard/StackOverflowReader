//
//  SearchHistoryTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/23/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class SearchHistoryTableViewCell: UITableViewCell
{
    @IBOutlet weak var scoreLabel: UILabel!  // Common
    @IBOutlet weak var titleLabel: UILabel!  // Common
    @IBOutlet weak var dateLabel: UILabel!  // Common
    
    @IBOutlet weak var authorNameButton: UIButton!
    
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
    }
    
    @IBAction func authorNameButtonPressed(_ sender: UIButton) {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
