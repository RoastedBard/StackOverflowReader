//
//  IntermediateCommon.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

class IntermediateCommon
{
    var owner : IntermediateShallowUser?
    var score : Int = 0
    var creationDate : Date = Date()
    var body : NSAttributedString = NSAttributedString() // For presenting
    var bodyOriginal : String = "" // For storing in the database
    
    init(shallowUser : ShallowUser?, score : Int, creationDate : Int, body : String, contentWidth : CGFloat)
    {
        if let owner = shallowUser {
            self.owner = IntermediateShallowUser(owner)
        }
        
        self.score = score
        
        self.creationDate = Date(timeIntervalSince1970: TimeInterval(creationDate))
        
        self.bodyOriginal = body
        
        self.body = body.htmlAttributedString ?? NSAttributedString()
        adjustImagesInAttributedString(self.body, contentWidth)
    }
    
    init(shallowUser : ShallowUserMO?, score : Int, creationDate : Int, body : String, contentWidth : CGFloat)
    {
        if let owner = shallowUser {
            self.owner = IntermediateShallowUser(owner)
        }
        
        self.score = score
        self.creationDate = Date(timeIntervalSince1970: TimeInterval(creationDate))
        
        self.bodyOriginal = body
        
        self.body = body.htmlAttributedString ?? NSAttributedString()
        
        if body != "" {
            adjustImagesInAttributedString(self.body, contentWidth)
        }
    }
    
    fileprivate func adjustImagesInAttributedString(_ attributedString : NSAttributedString, _ width : CGFloat)
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

