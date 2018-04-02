//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class AnswerView: UITableViewHeaderFooterView
{
    // MARK: - UI Elements
    
    @IBOutlet weak var answerScoreLabel: UILabelWithBorderAndInsets!
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!
    @IBOutlet weak var authorAndDateView: AuthorAndDateInfoView!
    @IBOutlet weak var backgroundColorView: UIView!
    
    // MARK: - Delegates
    
    var authorNamePressedDelegate : AuthorNamePressedProtocol?
    
    // MARK: - Properties
    
    var ownerUserId : Int = -1
    var answerId : Int = -1
    
    // MARK: - Lifecycle
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
    }
    
    // MARK: - Methods
    
    func initializeAnswerView(with answer : IntermediateAnswer, _ profilePicture : UIImage?)
    {
        answerScoreLabel.text = "\(answer.score)"
        
        answerBodyTextView.attributedText = answer.body
        
        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        authorAndDateView.fillViewWithData(date: dateFormatter.string(from: answer.creationDate), authorName: answer.owner?.displayName?.string, authorImageURL: answer.owner?.profileImage, userId: answer.owner?.userId)
        
//        if answer.comments != nil {
//            let showCommentsButton = UIButton()
//            showCommentsButton.translatesAutoresizingMaskIntoConstraints = false
//            showCommentsButton.setTitle("Show Comments", for: .normal)
//            showCommentsButton.setTitleColor(.white, for: .normal)
//            showCommentsButton.backgroundColor = .purple
//            showCommentsButton.sizeToFit()
//            
//            self.addSubview(showCommentsButton)
//            
//            
//            authorAndDateView.bottomAnchor.constraint(equalTo: showCommentsButton.topAnchor, constant: 8).isActive = true
//            showCommentsButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 8).isActive = true
//            showCommentsButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
//            showCommentsButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
//            
//            self.layoutSubviews()
//        }
        
//        if answer.comments == nil, showCommentsButton != nil, showCommentsButton.isDescendant(of: self) {
//            showCommentsButton.removeFromSuperview()
//            authorAndDateView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8).isActive = true
//        }
        
        self.ownerUserId = answer.owner?.userId ?? -1
        self.answerId = answer.answerId
        
        self.sendSubview(toBack: backgroundColorView)
    }
}
