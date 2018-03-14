//
//  SettingsViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController
{
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var myProfileButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if AuthorizationManager.isAuthorized == false {
            myProfileButton.removeFromSuperview()
            logOutButton.setTitle("Return to login screen", for: .normal)
        }
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
    
    @IBAction func myProfileButtonPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "ShowMyProfileSegue", sender: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton)
    {
        AuthorizationManager.logout {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
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
