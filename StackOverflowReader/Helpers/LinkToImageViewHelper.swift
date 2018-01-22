//
//  LinkToImageViewHelper.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/12/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit.UIImageView
import UIKit.UIImage

class LinkToImageViewHelper
{
    static func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ())
    {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    static func downloadImage(from url: URL, to imageView : UIImageView)
    {
        getDataFromUrl(url: url) { data, response, error in
            
            let httpResponse = response as! HTTPURLResponse
            
            if httpResponse.statusCode > 400 {
                print(">Profile image failed to load with status code: \(httpResponse.statusCode)")
                return
            }
            
            print("httpResponse.statusCode: \(httpResponse.statusCode)")
            
            guard let data = data, error == nil else{
                return
            }
            
            print(response?.suggestedFilename ?? url.lastPathComponent)
            
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
            }
        }
    }
}
