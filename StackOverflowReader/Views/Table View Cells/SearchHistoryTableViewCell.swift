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
    // MARK: - UI Elements
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorNameButton: UIButton!
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
    }
    
    // MARK: - Actions
    
    @IBAction func authorNameButtonPressed(_ sender: UIButton) {
        authorNamePressedDelegate?.authorNamePressed(userId: ownerUserId)
    }
}
