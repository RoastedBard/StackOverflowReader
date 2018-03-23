//
//  UILabelWithBorderAndInsets.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/22/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class UILabelWithBorderAndInsets: UILabel
{
    var textInsets = UIEdgeInsets.zero
    {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect
    {
        let insetRect = UIEdgeInsetsInsetRect(bounds, textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        
        return UIEdgeInsetsInsetRect(textRect, invertedInsets)
    }
    
    override func drawText(in rect: CGRect)
    {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, textInsets))
    }
}

// UILabelWithBorderAndInsets
@IBDesignable
extension UILabelWithBorderAndInsets
{
    @IBInspectable
    var cornerRadius: CGFloat
    {
        get { return layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    
    @IBInspectable
    var borderWidth: CGFloat
    {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable
    var borderColor: UIColor?
    {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var leftTextInset: CGFloat
    {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat
    {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat
    {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat
    {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}
