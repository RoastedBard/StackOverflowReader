//
//  HTMLToAttributedTextHelper.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/30/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

extension String
{
    // Converts HTML string to a `NSAttributedString`
    var htmlAttributedString: NSAttributedString?
    {
        return try? NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}
