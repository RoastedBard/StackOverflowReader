//
//  CommonModelData.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 2/8/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class CommonModelData : Codable
{
    // MARK: - Properties returned from API call
    
    var owner : ShallowUser?
    var score : Int = 0
    var creationDate : Int = 0 // unix epoch time
    var body : String = ""
    
    private enum CodingKeys : String, CodingKey
    {
        case creationDate = "creation_date"
        case owner
        case score
        case body
    }
    
    // MARK: - init
    
    init() {}
    
    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.owner = try? container.decode(ShallowUser.self, forKey: .owner)
        self.score = try container.decode(Int.self, forKey: .score)
        self.creationDate = try container.decode(Int.self, forKey: .creationDate)
        self.body = try container.decode(String.self, forKey: .body)
    }
    
    func encode(to encoder: Encoder) throws {
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(owner, forKey: .owner)
        try container.encode(score, forKey: .score)
        try container.encode(body, forKey: .body)
        try container.encode(creationDate, forKey: .creationDate)
        
    }
}
