//
//  IntermediateShallowUser.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class IntermediateShallowUser
{
    // MARK: - Properties
    
    var userId : Int?
    var profileImage : String?
    var displayName : NSAttributedString?
    
    // MARK: - Init
    
    init(userId : Int, profileImage : String, displayName : String)
    {
        self.userId = userId
        self.profileImage = profileImage
        self.displayName = displayName.htmlAttributedString
    }
    
    init(_ shallowUser : ShallowUser)
    {
        self.userId = shallowUser.userId
        self.profileImage = shallowUser.profileImage
        self.displayName = shallowUser.displayName?.htmlAttributedString
    }
    
    init(_ shallowUser : ShallowUserMO)
    {
        self.userId = Int(shallowUser.userId)
        self.profileImage = shallowUser.profileImage
        self.displayName = shallowUser.displayName?.htmlAttributedString
    }
}
