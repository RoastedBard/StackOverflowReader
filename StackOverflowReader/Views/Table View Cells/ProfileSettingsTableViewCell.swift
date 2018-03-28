//
//  ProfileSettingsTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class ProfileSettingsTableViewCell: UITableViewCell
{
    // MARK: - UI Elements
    
    @IBOutlet weak var myProfileButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var logOutButtonTopConstraint: NSLayoutConstraint!
    
    // MARK: - Delegates
    
    var profileSettingsDelegate : ProfileSettingsProtocol?
    
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
    
    @IBAction func myProfileButtonPressed()
    {
        profileSettingsDelegate?.myProfileAction()
    }
    
    @IBAction func logoutButtonPressed()
    {
        profileSettingsDelegate?.logOutAction()
    }
}
