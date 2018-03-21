//
//  HistorySettingsTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/21/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class HistorySettingsTableViewCell: UITableViewCell
{
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func clearHistorySwitchValueChanged(_ sender: UISwitch) {
        SearchHistoryManager.shouldDeleteHistory = sender.isOn
    }
}
