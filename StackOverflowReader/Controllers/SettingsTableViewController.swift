//
//  SettingsTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController
{
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if AuthorizationManager.isAuthorized == true {
            switch section {
            case 0:
                return "Search Settings"
            case 1:
                return "Profile Settings"
            default:
                return ""
            }
        } else {
            switch section {
            case 0:
                return "Search Settings"
            case 1:
                return "Profile Settings"
            default:
                return ""
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cellIdentifier = ""
        
        if indexPath.section == 0 {
            cellIdentifier = "SearchSettingsCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchSettingsTableViewCell else {
                exit(0)
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            cellIdentifier = "ProfileSettingsCell"
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProfileSettingsTableViewCell else {
                exit(0)
            }
            
            cell.profileSettingsDelegate = self
            
            if AuthorizationManager.isAuthorized == false {
                cell.myProfileButton.removeFromSuperview()
                cell.logOutButton.setTitle("Return to login screen", for: .normal)
                cell.logOutButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0)
            }
            
            return cell
        } else {
            cellIdentifier = "ErrorSettingsCell"
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            return cell
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowMyProfileSegue" {
            if let userTabBarController = segue.destination as? UserProfileTabBarController {
                guard let userProfileController = userTabBarController.viewControllers![0] as? UserViewController else {
                    print("Unable to get UserViewController")
                    return
                }
                
                userProfileController.isLoggedUserProfile = true
            }
        }
    }
}

// MARK: - ProfileSettingsProtocol

extension SettingsTableViewController : ProfileSettingsProtocol
{
    func myProfileAction()
    {
        performSegue(withIdentifier: "ShowMyProfileSegue", sender: nil)
    }
    
    func logOutAction()
    {
        AuthorizationManager.logout {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
