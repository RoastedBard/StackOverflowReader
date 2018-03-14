//
//  StringExtension.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/2/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import Foundation

extension String
{
    func index(of string: String, options: CompareOptions = .literal) -> Index?
    {
        return range(of: string, options: options)?.lowerBound
    }
    
    func endIndex(of string: String, options: CompareOptions = .literal) -> Index?
    {
        return range(of: string, options: options)?.upperBound
    }
    
    func indexes(of string: String, options: CompareOptions = .literal) -> [Index]
    {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex)
        {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>]
    {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex){
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    
    // Converts HTML string to a NSAttributedString
    var htmlAttributedString: NSAttributedString?
    {
        return try? NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}
