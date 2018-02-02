//
//  APICallWrapper.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/26/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation

enum SearchSortingType : String
{
    case activity
    case votes
    case creation
    case relevance
}

class APICallHelper
{
    static var currentPage : Int = 1
    static var apiRoot : String = "https://api.stackexchange.com/"
    static var apiVersion : String = "2.2"
    static var sort : SearchSortingType = .votes
    static let searchFilter : String = "!FH4kGNU5*mKF.Xy99s-h6.(B15HzE8P6_uK6oJxTFlxuApd(gSND2.n3pMWnC4BiNn5g-dR1"
    static let userFilter : String = "!)68_FgmiaW_vPRP3ip2yGAy1Sesu"
    
    static func searchAPICall(_ searchQuery : String, updateUIClosure: @escaping () -> Void) {
        let url = URL(string: "\(apiRoot)\(apiVersion)/search/advanced?page=\(currentPage)&order=desc&pagesize=30&sort=\(sort.rawValue)&q=\(searchQuery)&site=stackoverflow&filter=\(searchFilter)")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                
                QuestionsContainer.apiResponse = try! decoder.decode(APIResponseWrapper.self, from: data)
                
                if QuestionsContainer.questions == nil {
                    QuestionsContainer.questions = QuestionsContainer.apiResponse!.items
                } else {
                    QuestionsContainer.questions! += QuestionsContainer.apiResponse!.items
                }
                
                QuestionsContainer.apiResponse?.items.removeAll()
                
                DispatchQueue.main.async {
                    updateUIClosure()
                }
            }
        }
        
        task.resume()
    }
    
//    static func userAPICall(_ userId : Int, updateUIClosure: @escaping () -> Void) {
//        let url = URL(string: "https://api.stackexchange.com/2.2/users/\(userId)?order=desc&sort=reputation&site=stackoverflow&filter=\(userFilter)")!
//
//        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if let data = data {
//                let decoder = JSONDecoder()
//
//                self.user = try! decoder.decode(UserWrapper.self, from: data).user![0]
//
//                DispatchQueue.main.async {
//                    self.fillViewWithUserData()
//                }
//            }
//        }
//
//        task.resume()
//    }
}
