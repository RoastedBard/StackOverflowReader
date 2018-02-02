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
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var questionIndex = 0
    
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
    
    func initCell(question : Question, index : Int)
    {
        titleLabel.text = question.title.htmlAttributedString?.string
        
        scoreLabel.text = "\(question.score)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        let date = Date(timeIntervalSince1970: TimeInterval(question.creationDate))
        
        dateFormatter.locale = Locale(identifier: "en_US")
        
        dateLabel.text = "\(dateFormatter.string(from: date))"
        
        questionIndex = index
    }
}
