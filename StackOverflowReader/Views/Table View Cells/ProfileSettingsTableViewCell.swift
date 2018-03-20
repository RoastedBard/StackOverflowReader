//
//  ProfileSettingsTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

protocol ProfileSettingsProtocol {
    func myProfileAction()
    func logOutAction()
}

class ProfileSettingsTableViewCell: UITableViewCell
{
    // MARK: - Outlets
    
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var logOutButtonTopConstraint: NSLayoutConstraint!
    
    // MARK: - Delegate
    
    var profileSettingsDelegate : ProfileSettingsProtocol?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Actions
    
    @IBAction func myProfileButtonPressed()
    {
        profileSettingsDelegate?.myProfileAction()
    }
    
    @IBAction func logoutButtonPressed()
    {
        profileSettingsDelegate?.logOutAction()
    }
}
