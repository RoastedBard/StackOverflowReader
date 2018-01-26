//
//  APICallWrapper.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/26/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

struct APIResponseWrapper : Codable
{
    var items : [Question]
}
