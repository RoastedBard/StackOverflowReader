//
//  AnswerView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}

class AnswerView: UITableViewHeaderFooterView
{
    @IBOutlet weak var answerScoreLabel: UILabel!
    @IBOutlet weak var answerAcceptedPicture: UIImageView!
    @IBOutlet weak var answerBodyTextView: UITextView!
    
    @IBOutlet weak var answerAuthorNameButton: UIButton!
    @IBOutlet weak var answerDateLabel: UILabel!
    @IBOutlet weak var answerAuthorProfileImage: UIImageView!
    
    var profileImage : UIImage?
    
    var delegate : AuthorNamePressedProtocol?
    
    var owner : ShallowUser?
    
    var attributedAnswerBodyString : NSAttributedString?
    var attributedAnswerAuthorString : NSAttributedString?
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initializeAnswerView(_ answer : Answer, screenWidth width : CGFloat, _ attributedData : CommonAttributedData)
    {
        answerScoreLabel.text = "\(answer.score)"
        
        answerBodyTextView.attributedText = attributedData.attributedBodyString
        
        answerAuthorNameButton.setTitle(attributedData.attributedAuthorNameString?.string ?? "NOT_SPECIFIED", for: .normal)

        if answer.isAccepted == true {
            answerAcceptedPicture.isHidden = false
        } else {
            answerAcceptedPicture.isHidden = true
        }
        
        if let owner = answer.owner {
            if let userImageLink = owner.profileImage {
                if let url = URL(string: userImageLink) {
                    LinkToImageViewHelper.downloadImage(from: url, to: answerAuthorProfileImage)
                }
            }
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(answer.creationDate))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        answerDateLabel.text = "\(dateFormatter.string(from: date))"
    }

    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        delegate?.authorNamePressed(userId: owner?.userId ?? -1)
    }
    
    func adjustImagesInAttributedString(_ attributedString : NSAttributedString, _ width : CGFloat)
    {
        let range = NSMakeRange(0, attributedString.length)
        
        attributedString.enumerateAttributes(in: range, options: NSAttributedString.EnumerationOptions(rawValue: 0)) { (object, range, stop) in
            if object.keys.contains(NSAttributedStringKey.attachment) {
                if let attachment = object[NSAttributedStringKey.attachment] as? NSTextAttachment {
                    if attachment.image != nil {
                        let aspectRatio : CGFloat = attachment.bounds.size.width / attachment.bounds.size.height
                        let newHeight : CGFloat = width / aspectRatio
                        
                        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: 0 ), size: CGSize(width: width, height: newHeight))
                    } else if attachment.image(forBounds: attachment.bounds, textContainer: nil, characterIndex: range.location) != nil {
                        
                        let aspectRatio : CGFloat = attachment.bounds.size.width / attachment.bounds.size.height
                        let newHeight : CGFloat = width / aspectRatio
                        
                        attachment.bounds = CGRect(origin: CGPoint(x: 0, y: 0 ), size: CGSize(width: width, height: newHeight))
                    }
                }
            }
        }
    }
}
