//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/11/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class QuestionView: UITableViewHeaderFooterView
{
    @IBOutlet weak var questionTitleLabel: UILabel!
    @IBOutlet weak var questionScoreLabel: UILabel!
    @IBOutlet weak var questionBodyTextView: UITextView!
    
    @IBOutlet weak var questionDateLabel: UILabel!
    @IBOutlet weak var questionAuthorNameButton: UIButton!
    @IBOutlet weak var questionAuthorProfileImage: UIImageView!
    @IBOutlet weak var questionClosedReasonLabel: UILabel!
    
    var delegate : AuthorNamePressedProtocol?
    
    var owner : ShallowUser?
    
//    var attributedQuestionBodyString : NSAttributedString?
//    var attributedQuestionAuthorString : NSAttributedString?
//    var attributedQuestionTitleString : NSAttributedString?
    
//    func initializeQuestionView(_ question : Question, screenWidth width : CGFloat)
//    {
//        if question.closedReason != nil {
//            questionClosedReasonLabel.text = "CLOSED AS: \(question.closedReason!)"
//        }
//
//        attributedQuestionTitleString = question.title.htmlAttributedString
//        questionTitleLabel.text = attributedQuestionTitleString?.string
//
//        if let attributedString = question.body.htmlAttributedString {
//            attributedQuestionBodyString = attributedString
//
//            adjustImagesInAttributedString(attributedQuestionBodyString!, width)
//            questionBodyTextView.attributedText = attributedQuestionBodyString
//        } else {
//            attributedQuestionBodyString = nil
//            questionBodyTextView.text = ""
//        }
//
//        if let owner = question.owner {
//            attributedQuestionAuthorString = owner.displayName!.htmlAttributedString
//            questionAuthorNameButton.setTitle(attributedQuestionAuthorString!.string, for: .normal)
//        } else {
//            attributedQuestionAuthorString = nil
//            questionAuthorNameButton.setTitle("NOT_SPECIFIED", for: .normal)
//        }
//
//        questionScoreLabel.text = "\(question.score)"
//
//        if let owner = question.owner {
//            if let userImageLink = owner.profileImage {
//                if let url = URL(string: userImageLink) {
//                    LinkToImageViewHelper.downloadImage(from: url, to: questionAuthorProfileImage)
//                }
//            }
//        }
//
//        let date = Date(timeIntervalSince1970: TimeInterval(question.creationDate))
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.locale = Locale(identifier: "en_US")
//
//        questionDateLabel.text = "\(dateFormatter.string(from: date))"
//    }
    
    func initializeQuestionView(_ question : Question, screenWidth width : CGFloat, _ attributedData : QuestionAttributedData)
    {
        if question.closedReason != nil {
            questionClosedReasonLabel.text = "CLOSED AS: \(question.closedReason!)"
        }
        
        questionTitleLabel.text = attributedData.attributedQuestionTitle?.string ?? "NOT_SPECIFIED"
        
        questionBodyTextView.attributedText = attributedData.attributedBodyString
        
        questionAuthorNameButton.setTitle(attributedData.attributedAuthorNameString?.string ?? "NOT_SPECIFIED", for: .normal)
        
        questionScoreLabel.text = "\(question.score)"
        
        if let owner = question.owner {
            if let userImageLink = owner.profileImage {
                if let url = URL(string: userImageLink) {
                    LinkToImageViewHelper.downloadImage(from: url, to: questionAuthorProfileImage)
                }
            }
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(question.creationDate))
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US")
        
        questionDateLabel.text = "\(dateFormatter.string(from: date))"
    }
    
    @IBAction func authorNamePressed(_ sender: UIButton)
    {
        delegate?.authorNamePressed(owner)
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
