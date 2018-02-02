//
//  HTMLToAttributedTextHelper.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/30/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class HTMLStringToAttributedTextHelper
{
    func makeAttributedText(from html : String) -> NSAttributedString
    {
        let htmlData = NSString(string: html).data(using: String.Encoding.unicode.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!, options: options, documentAttributes: nil)
    }
}
