//
//  AuthorAndDateInfoView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/26/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class AuthorAndDateInfoView: UIView
{
    //MARK: - UI Elements
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorNameButton: UIButton!
    @IBOutlet weak var authorProfileImage: UIImageView!
    var profileImageLoadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: - Properties
    
    let nibName = "AuthorAndDateInfoView"
    var authorNamePressedDelegate : AuthorNamePressedProtocol?
    var userId : Int = -1
    
    // MARK: - Initializers
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        guard let view = loadViewFromNib() else { return }
        view.frame = self.bounds
        self.addSubview(view)
        contentView = view
    }
    
    // MARK: - Methods
    
    func loadViewFromNib() -> UIView?
    {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as? UIView
    }
    
    func fillViewWithData(date: String, authorName: String?, authorImageURL: String?, userId: Int?)
    {
        authorProfileImage.addSubview(profileImageLoadingIndicator)
        
        profileImageLoadingIndicator.centerXAnchor.constraint(equalTo: authorProfileImage.centerXAnchor).isActive = true
        profileImageLoadingIndicator.centerYAnchor.constraint(equalTo: authorProfileImage.centerYAnchor).isActive = true
        
        authorProfileImage.bringSubview(toFront: profileImageLoadingIndicator)
        
        dateLabel.text = date
        authorNameButton.setTitle(authorName, for: .normal)
        authorNameButton.sizeToFit()
        
        guard let userId = userId else { return }
        
        if ProfileImagesStorage.profileImages[userId] == nil {
            
            profileImageLoadingIndicator.startAnimating()
            
            if let urlString = authorImageURL, let url = URL(string: urlString) {
                LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                    guard let sSelf = self else { return }
                    DispatchQueue.main.async {
                        sSelf.authorProfileImage.image = image
                        ProfileImagesStorage.profileImages[userId] = image
                        sSelf.profileImageLoadingIndicator.stopAnimating()
                        sSelf.profileImageLoadingIndicator.removeFromSuperview()
                    }
                }
            }
        } else {
            self.authorProfileImage.image = ProfileImagesStorage.profileImages[userId]
        }
        
        //self.authorProfileImage.image = authorImage
        
        self.userId = userId ?? -1
    }
    
    // MARK: - Actions
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        authorNamePressedDelegate?.authorNamePressed(userId: userId)
    }
}
