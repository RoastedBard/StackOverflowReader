//
//  AttributedData.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/31/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

class CommonAttributedData
{
    var attributedBodyString : NSAttributedString?
    var attributedAuthorNameString : NSAttributedString?
    
    init(body : String, authorName : String, contentWidth : CGFloat) {
        attributedBodyString = body.htmlAttributedString
        adjustImagesInAttributedString(attributedBodyString!, contentWidth)
        
        attributedAuthorNameString = authorName.htmlAttributedString
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

class QuestionAttributedData : CommonAttributedData
{
    var attributedQuestionTitle : NSAttributedString?
    
    init(title : String, body : String, authorName : String, contentWidth : CGFloat) {
        super.init(body: body, authorName: authorName, contentWidth: contentWidth)
        
        attributedQuestionTitle = title.htmlAttributedString
    }
}

