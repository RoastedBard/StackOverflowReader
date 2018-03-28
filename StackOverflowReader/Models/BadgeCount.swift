//
//  BadgeCount.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/22/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

struct BadgeCount : Codable
{
    // MARK: - Properties returned from API call
    
    var bronze : Int
    var silver : Int
    var gold : Int
}
