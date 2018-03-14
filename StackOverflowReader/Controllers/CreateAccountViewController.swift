//
//  CreateAccountViewController.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/1/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController
{
    // MARK : Constants
    let usernamesKey = "usernames"
    
    // MARK : IBOutlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func createNewAccountButtonPressed(_ sender: UIButton)
    {
        // Check if username and pasword text fields are not empty
        guard let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty,
            !newPassword.isEmpty else {
                showFailedAlert(message: "Wrong username or password.")
                return
        }
        
        let defaults = UserDefaults.standard
        
        // Retrieve an array of usernames from UserDefaults
        let users = defaults.stringArray(forKey: usernamesKey) ?? [String]()
        
        var usersSet = Set<String>(users)
        
        // Try to insert new username
        if usersSet.insert(newAccountName).inserted == false {
            showFailedAlert(message: "User with this username already exist")
            return
        }
        
        // Save array with new username added
        defaults.set(Array(usersSet), forKey: usernamesKey)
        
        do {
            // Create a new keychain item with the account name.
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: newAccountName,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            
            // Save the password for the new item.
            try passwordItem.savePassword(newPassword)
            
            performSegue(withIdentifier: "LoginSuccessSegue", sender: self)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    private func showFailedAlert(message : String)
    {
        let alertView = UIAlertController(title: "Account Creation Problem",
                                          message: message,
                                          preferredStyle:. alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
