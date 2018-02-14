//
//  SettingsViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

class SettingsViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    @IBAction func logoutButtonPressed(_ sender: UIButton)
    {
        let loginManager = LoginManager()
        
        loginManager.logOut()
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
