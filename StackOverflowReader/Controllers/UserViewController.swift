//
//  UserViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

struct UserWrapper : Codable {
    var user : [User]?
    
    enum CodingKeys: String, CodingKey
    {
        case user = "items"
    }
}

class UserViewController: UIViewController
{
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userReputationLabel: UILabel!
    @IBOutlet weak var userAgeLabel: UILabel!
    @IBOutlet weak var userAboutTextView: UITextView!
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userLocationLabel: UILabel!
    @IBOutlet weak var userAnswersCountLabel: UILabel!
    @IBOutlet weak var userQuestionsCountLabel: UILabel!
    @IBOutlet weak var userLastSeenLabel: UILabel!
    @IBOutlet weak var userProfileViewsLabel: UILabel!
    @IBOutlet weak var userMemberSinceLabel: UILabel!
    @IBOutlet weak var userWebsiteLinkLabel: UILabel!
    @IBOutlet weak var goldenBadgeCountLabel: UILabel!
    @IBOutlet weak var silverBadgeCountLabel: UILabel!
    @IBOutlet weak var bronzeBadgeCountLabel: UILabel!
    
    var userId : Int = 0
    var user : User?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if userId == -1 {
            print(">USER_INVALID_ID_ERROR: userId = -1")
            return
        }
        
        let url = URL(string: "https://api.stackexchange.com/2.2/users/\(userId)?order=desc&sort=reputation&site=stackoverflow&filter=!)68Yd_uOIq-c4mbge*PtmUY-nQ*H")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                
                do{
                    self.user = try decoder.decode(UserWrapper.self, from: data).user![0]
                } catch {
                    print(">USER_DECODING_ERROR: \(error)")
                }
                
                DispatchQueue.main.async {
                    self.fillViewWithUserData()
                }
            }
        }
        
        task.resume()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fillViewWithUserData()
    {
        userNameLabel.text = user?.displayName
        
        goldenBadgeCountLabel.text = "\(user!.badgeCounts.gold)"
        silverBadgeCountLabel.text = "\(user!.badgeCounts.silver)"
        bronzeBadgeCountLabel.text = "\(user!.badgeCounts.bronze)"
        
        if let userImageLink = user?.profileImage {
            if let url = URL(string: userImageLink) {
                LinkToImageViewHelper.downloadImage(from: url, to: userProfileImage)
            }
        }
        
        if user?.reputation != nil{
            userReputationLabel.text = "\(user!.reputation!)"
        }else{
            userReputationLabel.text = "unknown"
        }
        
        if user?.age != nil{
            userAgeLabel.text = "\(user!.age!)"
        }else{
            userAgeLabel.text = "unknown"
        }
        
        if user?.location != nil{
            userLocationLabel.text = "\(user!.location!)"
        }else{
            userLocationLabel.text = "unknown"
        }
        
        if user?.answerCount != nil{
            userAnswersCountLabel.text = "\(user!.answerCount!)"
        }else{
            userAnswersCountLabel.text = "unknown"
        }
        
        if user?.questionCount != nil{
            userQuestionsCountLabel.text = "\(user!.questionCount!)"
        }else{
            userQuestionsCountLabel.text = "unknown"
        }
        
        if user?.viewCount != nil{
            userProfileViewsLabel.text = "\(user!.viewCount!)"
        }else{
            userProfileViewsLabel.text = "unknown"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .full
       
        // Last seen
        if user?.lastAccessDate != nil{
            dateComponentsFormatter.maximumUnitCount = 4
            dateComponentsFormatter.allowedUnits = [.month, .year, .hour, .minute]
            
            let lastSeenDate = Date(timeIntervalSince1970: TimeInterval(user!.lastAccessDate!))
            let lastSeenString = dateComponentsFormatter.string(from: lastSeenDate, to: Date())
            
            userLastSeenLabel.text = "\(lastSeenString!) ago"
        }else{
            userLastSeenLabel.text = "unknown"
        }
        
        // Member since
        dateComponentsFormatter.maximumUnitCount = 2
        dateComponentsFormatter.allowedUnits = [.month, .year]
        
        let joinDate = Date(timeIntervalSince1970: TimeInterval(user!.creationDate))
        let memberForString = dateComponentsFormatter.string(from: joinDate, to: Date())
        
        userMemberSinceLabel.text = "\(memberForString!)"
        
        if user?.websiteUrl != nil{
            userWebsiteLinkLabel.text = "\(user!.websiteUrl!)"
        }else{
            userWebsiteLinkLabel.text = "unknown"
        }
        
        if user?.aboutMe != nil{
            userAboutTextView.text = "\(user!.aboutMe!)"
        }else{
            userAboutTextView.text = "unknown"
        }
    }
}
