//
//  GreetingScreenViewController.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/7/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import UIKit

class GreetingScreenViewController: UIViewController
{
    // MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool)
    {
        // Attempt login if access token is available
        AuthorizationManager.login() {
            
            // Read search settings from user defaults
            let userDefaults = UserDefaults.standard
            
            if let lastLoggedUser = userDefaults.string(forKey: "lastLoggedUser"), lastLoggedUser != "" {
                let pageSize = userDefaults.integer(forKey: "\(lastLoggedUser)_pageSize")
                UserSettings.searchPageSize = pageSize
            }
            
            self.performSegue(withIdentifier: "AlreadyLoggedInSegue", sender: nil)
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        
    }
}
