//
//  LoadMoreTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/21/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell
{
    // MARK: - UI Elements
    
    @IBOutlet weak var loadMoreButton: UIButton!
    @IBOutlet weak var loadMoreActivityIndicator: UIActivityIndicatorView!
    
    // MARK: - Delegates
    
    var loadMoreDelegate : LoadMoreQuestionsProtocol?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Actions
    
    @IBAction func loadMoreButtonPressed(_ sender: Any)
    {
        if let loadMore = loadMoreDelegate {
            loadMore.loadMoreQuestions(sender: loadMoreButton, activityIndicatorView: loadMoreActivityIndicator)
        }
    }
}
