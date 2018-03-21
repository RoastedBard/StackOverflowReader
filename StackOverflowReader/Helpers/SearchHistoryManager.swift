//
//  SearchHistoryManager.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/21/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

class SearchHistoryItem
{
    var searchQuery : String = ""
    var visitedQuestions : [IntermediateBriefQuestion] = [IntermediateBriefQuestion]()
    
    init(searchQuery : String)
    {
        self.searchQuery = searchQuery
    }
}

class SearchHistoryManager
{
    static var shouldDeleteHistory = false
    static var searchHistory : [SearchHistoryItem] = [SearchHistoryItem]()
}
