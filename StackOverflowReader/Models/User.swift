//
//  User.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/22/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import Foundation

struct User : Codable {
    let profilePictureURL : String?
    let userName : String?
    let reputation : Int?
    let about : String?
    let age : Int?
    let location : String?
    let website : String?
}
