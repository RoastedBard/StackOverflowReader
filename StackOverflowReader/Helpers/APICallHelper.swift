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

enum APIRequestType
{
    case BriefQuestionsRequest
    case FullQuestionRequest
    case UserRequest
}

struct APIResponseWrapper<T : Codable> : Codable
{
    var items : [T]?
}

class APICallHelper
{
    // MARK: - API call parts
    static var currentPage : Int = 1
    static var sort : SearchSortingType = .votes
    
    fileprivate static let applicationKey : String = "Q)4aM*Ox5tlnokGsMxWYlw(("
    fileprivate static let apiRoot : String = "https://api.stackexchange.com/"
    fileprivate static let apiVersion : String = "2.2"
    fileprivate static let pageSize : Int = 30
    
    // MARK: - Filters
    fileprivate static let briefQuestionsFilter : String = "!1PUgU9fzk83OSa1oSJXaAlJsqYYNwPOp4" // !1PUgU9fzk83OSa1oSJXaAlJsqYYNwPOp4 !PvyX(nrryVMTzZo))izCaw5I3DiEg8
    fileprivate static let fullQuestionsFilter : String = "!.PJ-a73kkFkIVFntcu(u(MlOi*44iZPnrfx077WD7_1BJrMTX7rdf3zP88d3U5"
    fileprivate static let userFilter : String = "!0YzIPZzz24xx9(INJ.yi*SI8a"
    
    fileprivate static var url : URL?
    
    // MARK: - Methods
    static func APICall<T>(request : APIRequestType, apiCallParameter : Any?, updateUIClosure: @escaping (_ apiCallWrapper : APIResponseWrapper<T>?) -> Void)
    {
        constructURL(request, apiCallParameter)
        executeAPICall(updateUIClosure)
    }
    
    fileprivate static func constructURL(_ request: APIRequestType, _ apiCallParameter: Any?)
    {
        switch request
        {
        case .BriefQuestionsRequest:
            let searchQuery = apiCallParameter as! String
            url = URL(string: "\(apiRoot)\(apiVersion)/search/advanced?site=stackoverflow&key=\(applicationKey)&page=\(currentPage)&pagesize=\(pageSize)&sort=\(sort.rawValue)&q=\(searchQuery)&filter=\(briefQuestionsFilter)")!
            
        case .FullQuestionRequest:
            let questionId = apiCallParameter as! Int
            url = URL(string: "\(apiRoot)\(apiVersion)/questions/\(questionId)?site=stackoverflow&key=\(applicationKey)&filter=\(fullQuestionsFilter)")!
            
        case .UserRequest:
            let userId = apiCallParameter as! Int
            url = URL(string: "\(apiRoot)\(apiVersion)/users/\(userId)?site=stackoverflow&key=\(applicationKey)&filter=\(userFilter)")!
        }
    }
    
    fileprivate static func executeAPICall<T>(_ updateUIClosure: @escaping (_ apiCallWrapper : APIResponseWrapper<T>?) -> Void) {
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                
                var apiResponse : APIResponseWrapper<T>?
                
                do{
                    apiResponse = try decoder.decode(APIResponseWrapper<T>.self, from: data)
                } catch {
                    print("\(error)")
                }
                
                DispatchQueue.main.async {
                    updateUIClosure((apiResponse != nil) ? apiResponse : nil)
                }
            }
        }
        
        task.resume()
    }
}
