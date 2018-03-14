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
        guard let indexOfQuerySeparator = queryParameters.index(of: "&") else {
            return nil
        }
        
        let range = indexOfValueKey..<indexOfQuerySeparator
        
        let value = queryParameters[range]
        
        return String(value)
    }
    
    static func showFailedAlert(_ viewController : UIViewController, title : String, message : String)
    {
        let alertView = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle:. alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertView.addAction(okAction)
        viewController.present(alertView, animated: true)
    }
}
