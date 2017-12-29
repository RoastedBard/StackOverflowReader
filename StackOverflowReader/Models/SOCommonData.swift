//
//  SOCommonData.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/22/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import Foundation

class SOCommonData : Codable {
    let author : User?
    let body : String?
    let votes : Int?
    let date : Date?
}
