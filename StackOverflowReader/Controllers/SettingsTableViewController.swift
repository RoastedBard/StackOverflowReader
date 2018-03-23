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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
//        if AuthorizationManager.isAuthorized == true {
//            return 3
//        } else {
//            return 2
//        }
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
//                return "History Settings"
//            case 2:
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowMyProfileSegue" {
            guard let userController = segue.destination as? UserViewController else {
                return
            }
            
            userController.isLoggedUserProfile = true
        }
    }
}

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
