//
//  Utility.swift
//  StackOverflowAuth
//
//  Created by Ruslan Lezhnin on 3/8/18.
//  Copyright © 2018 Ruslan Lezhnin. All rights reserved.
//

import Foundation
import UIKit

class Utility
{
    static func parseUrlForValue(url : String, valueForKey : String) -> String?
    {
        guard let indexOfHashTag = url.index(of: "#") else {
            return nil
        }

        let queryParameters = String(url.suffix(from: indexOfHashTag))

        guard let indexOfValueKey = queryParameters.endIndex(of: valueForKey + "=") else {
            return nil
        }
        
        var value = ""
        
        if let indexOfQuerySeparator = queryParameters.index(of: "&") {
            let range = indexOfValueKey..<indexOfQuerySeparator
            
            value = String(queryParameters[range])
        } else {
            let range = indexOfValueKey..<queryParameters.endIndex
            
            value = String(queryParameters[range])
        }
        
        return String(value)
    }
    
    static func showAlert(_ viewController : UIViewController, title : String, message : String)
    {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle:. alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertView.addAction(okAction)
        viewController.present(alertView, animated: true)
    }
    
    static func showConfirmationDialog(_ viewController : UIViewController, title : String, message : String, okAction: @escaping () -> Void)
    {
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            okAction()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        
        viewController.present(dialogMessage, animated: true, completion: nil)
    }
}
