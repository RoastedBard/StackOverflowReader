//
//  IntermediateBadgeCount.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class IntermediateBadgeCount
{
    // MARK: - Properties
    
    var bronze : Int
    var silver : Int
    var gold : Int
    
    // MARK: - Init
    
    init(_ badgeCountCodable : BadgeCount)
    {
        self.bronze = badgeCountCodable.bronze
        self.silver = badgeCountCodable.silver
        self.gold = badgeCountCodable.gold
    }
}
