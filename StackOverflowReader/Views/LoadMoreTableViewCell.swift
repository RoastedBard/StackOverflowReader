//
//  LoadMoreTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/21/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

protocol LoadMoreQuestionsProtocol
{
    func loadMoreQuestions(sender : UIButton, activityIndicatorView : UIActivityIndicatorView)
}

class LoadMoreTableViewCell: UITableViewCell
{
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!
    
    var loadMoreDelegate : LoadMoreQuestionsProtocol?
    
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

    @IBAction func loadMoreButtonPressed(_ sender: Any)
    {
        if let loadMore = loadMoreDelegate {
            loadMore.loadMoreQuestions(sender: loadMoreButton, activityIndicatorView: loadMoreActivityIndicator)
        }
    }
}
