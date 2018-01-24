//
//  UserViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class UserViewController: UIViewController
{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userReputationLabel: UILabel!
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var userAboutTextView: UITextView!
    @IBOutlet weak var userProfileImage: UIImageView!
    
    var user : ShallowUser?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        userNameLabel.text = user?.displayName
        
        if let userImageLink = user?.profileImage {
            if let url = URL(string: userImageLink) {
                LinkToImageViewHelper.downloadImage(from: url, to: userProfileImage)
            }
        }
        
//        if user?.reputation != nil{
//            userReputationLabel.text = "\(user!.reputation!)"
//        }else{
            userReputationLabel.text = "unknown"
//        }
        
        userAgeLabel.text = "NOT_SUPPORTED"
        userAboutTextView.text = "NOT_SUPPORTED"
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
