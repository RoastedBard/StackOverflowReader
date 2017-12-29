//
//  Question.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/22/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import Foundation

class Question : SOCommonData {
    var title : String?
    var answers: [Answer]? = nil
    var comments : [Comment]? = nil
    var acceptedAnswer : Answer? = nil
}
