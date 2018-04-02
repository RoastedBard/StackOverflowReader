//
//  SearchSettingsTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class SearchSettingsTableViewCell: UITableViewCell
{
    // MARK: - UI Elements
    
    @IBOutlet weak var searchResultsOnPageSlider: UISlider!
    @IBOutlet weak var searchResultsOnPageLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        searchResultsOnPageSlider.value = Float(APICallHelper.pageSize)
        searchResultsOnPageLabel.text = "Search results on page: \(APICallHelper.pageSize)"
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Actions
    
    @IBAction func resultsOnPageSliderValueChanged(_ sender: UISlider)
    {
        let value = Int(sender.value)
        APICallHelper.pageSize = value
        searchResultsOnPageLabel.text = "Search results on page: \(value)"
    }
    
}
