//
//  UserViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import WebKit

class UserViewController: UIViewController
{
    // MARK: - UI Elements
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userReputationLabel: UILabel!
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var userAboutTextView: UITextView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userLastSeenLabel: UILabel!
    @IBOutlet weak var userProfileViewsLabel: UILabel!
    @IBOutlet weak var userMemberSinceLabel: UILabel!
    @IBOutlet weak var userWebsiteLinkLabel: UILabel!
    @IBOutlet weak var goldenBadgeCountLabel: UILabel!
    @IBOutlet weak var silverBadgeCountLabel: UILabel!
    @IBOutlet weak var bronzeBadgeCountLabel: UILabel!
    
    // MARK: - Properties
    
    var profilePicture : UIImage?
    var userId : Int = 0
    var user : IntermediateUser?
    let dispatchQueue = DispatchQueue(label: "LoadingQuestionData", attributes: [], target: nil)
    var isLoggedUserProfile = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if isLoggedUserProfile == true {
            self.user = AuthorizationManager.authorizedUser
            self.fillViewWithUserData()
        } else {
            guard let tabBarController = self.tabBarController as? UserProfileTabBarController else {
                print("Failed to get tab bar controller")
                return
            }
            
            userId = tabBarController.userId
            
            print("userId = \(userId)")
            
            if userId == -1 {
                print(">USER_INVALID_ID_ERROR: userId = -1")
                return
            }
            
            DispatchQueue.global(qos: .userInitiated) .async {
                APICallHelper.APICall(request: APIRequestType.UserRequest, apiCallParameter: self.userId){ (apiWrapperResult : APIResponseWrapper<User>?) in
                    guard let userModel = apiWrapperResult?.items?[0] else {
                        print("Failed to convert user model to intermediate model")
                        return
                    }
                    
                    self.user = IntermediateUser(userModel)
                    
                    self.fillViewWithUserData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    
    private func fillViewWithUserData()
    {
        if let user = user {
            // User name
            if let displayName = user.displayName {
                userNameLabel.text = displayName.string
            }
            
            // Badges count
            if let badgeCounts = user.badgeCounts {
                goldenBadgeCountLabel.text = "\(badgeCounts.gold)"
                silverBadgeCountLabel.text = "\(badgeCounts.silver)"
                bronzeBadgeCountLabel.text = "\(badgeCounts.bronze)"
            }
            
            // Profile image
            if let picture = profilePicture {
                userProfileImage.image = picture
            } else {
                if let profileImageLink = user.profileImage {
                    if let url = URL(string: profileImageLink) {
                        LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                            guard let sSelf = self else { return }
                            DispatchQueue.main.async {
                                sSelf.userProfileImage.image = image
                                print("user image loaded")
                            }
                        }
                    }
                }
            }
            
            // Reputation
            if let reputation = user.reputation{
                userReputationLabel.text = "\(reputation)"
            }else{
                userReputationLabel.text = "unknown"
            }
            
            // Age
            if let age = user.age {
                userAgeLabel.text = "\(age)"
            }else{
                userAgeLabel.text = "unknown"
            }
            
            // Location
            if let location = user.location{
                userLocationLabel.text = location.string
            }else{
                userLocationLabel.text = "unknown"
            }
            
            // View Count
            if let viewCount = user.viewCount{
                userProfileViewsLabel.text = "\(viewCount)"
            }else{
                userProfileViewsLabel.text = "unknown"
            }
            
            // Dates
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.unitsStyle = .full
            
            // Last seen
            if let lastAccessDate = user.lastAccessDate {
                dateComponentsFormatter.maximumUnitCount = 4
                dateComponentsFormatter.allowedUnits = [.month, .year, .hour, .minute]
                
                let lastSeenDate = Date(timeIntervalSince1970: TimeInterval(lastAccessDate))
                if let lastSeenString = dateComponentsFormatter.string(from: lastSeenDate, to: Date()) {
                    userLastSeenLabel.text = "\(lastSeenString) ago"
                } else {
                    userLastSeenLabel.text = "Error in formatting date"
                }
            }else{
                userLastSeenLabel.text = "unknown"
            }
            
            // Member since
            dateComponentsFormatter.maximumUnitCount = 2
            dateComponentsFormatter.allowedUnits = [.month, .year]
            
            let joinDate = Date(timeIntervalSince1970: TimeInterval(user.creationDate))
            let memberForString = dateComponentsFormatter.string(from: joinDate, to: Date())
            
            userMemberSinceLabel.text = "\(memberForString!)"
            
            // User website
            if let websiteUrl = user.websiteUrl {
                userWebsiteLinkLabel.text = websiteUrl.htmlAttributedString?.string
            }else{
                userWebsiteLinkLabel.text = "unknown"
            }
            
            // About me
            if let aboutMe = user.aboutMe {
                userAboutTextView.text = aboutMe.string
            }else{
                userAboutTextView.text = "unknown"
            }
        }
    }
}
