//
//  UITextViewFixed.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/27/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

// UITextView with zero insets
@IBDesignable
class UITextViewFixed: UITextView
{
    override func layoutSubviews()
    {
        super.layoutSubviews()
        setup()
    }
    
    func setup()
    {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
