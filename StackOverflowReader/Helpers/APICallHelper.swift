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
    case SearchBriefQuestionsRequest
    case BriefQuestionsRequest
    case FullQuestionRequest
    case UserRequest
    case MyAccountRequest
    case LogOutRequest
    case ValidateAccessTokenRequest
    case GetUserQuestions
    case GetUserAnswers
    case GetMyQuestions
    case GetMyAnswers
}

struct APIResponseWrapper<T : Codable> : Codable
{
    var items : [T]?
    var total : Int?
    var hasMore : Bool?
    
    enum CodingKeys : String, CodingKey
    {
        case hasMore = "has_more"
        case items
        case total
    }
}

struct APICallParameters
{
    var currentPage : Int = 1
    var sort : SearchSortingType = .votes
    var pageSize : Int = 30
    //var requestType : APIRequestType
}
    
class APICallHelper
{
    // MARK: - API call parts
    
    fileprivate static let applicationKey : String = "Q)4aM*Ox5tlnokGsMxWYlw(("
    fileprivate static let apiRoot : String = "https://api.stackexchange.com/"
    fileprivate static let apiVersion : String = "2.2"
    
    // MARK: - Filters
    
    fileprivate static let briefQuestionsFilter = "!1PUgU9fzk8OTrwiO(l_6bIsha)5ivzsYW"
    fileprivate static let fullQuestionsFilter = "!v)Cpd1)X)148G5bcy7XHn8n(yDS2yxYNtCnCv(qRtnF2EdvtdCwYkdOHiOpBLI(X"
    fileprivate static let userFilter = "!BTTDH9mpUuRPJUS4dOfslFqNDXMy.C"
    fileprivate static let accessTokenInfoFilter = "!-.-gvNflsiZx"
    fileprivate static let userQuestionsFilter = "!)Ehtmgj(tvg-5.lcA5tOoZmem1aA_v5hYABG2n(aCRgoNLqrl"
    fileprivate static let userAnswersFilter = "!)Q29mbLxf6w-Je1B4y.ajpy_"
    
    fileprivate static var url : URL?
    
    // MARK: - Methods
    
    static func APICall<T>(request : APIRequestType, apiCallParameter : Any?, apiCallParameters: APICallParameters?, updateUIClosure: @escaping (_ apiCallWrapper : APIResponseWrapper<T>?) -> Void)
    {
        constructURL(request, apiCallParameters: apiCallParameters, apiCallParameter)
        executeAPICall(updateUIClosure)
    }
    
    fileprivate static func constructURL(_ request: APIRequestType, apiCallParameters: APICallParameters?, _ apiCallParameter: Any?)
    {
        switch request
        {
        case .SearchBriefQuestionsRequest:
            if let apiCallParameters = apiCallParameters {
                let searchQuery = apiCallParameter as! String
                url = URL(string: "\(apiRoot)\(apiVersion)/search/advanced?site=stackoverflow&key=\(applicationKey)&page=\(apiCallParameters.currentPage)&pagesize=\(apiCallParameters.pageSize)&sort=\(apiCallParameters.sort.rawValue)&q=\(searchQuery)&filter=\(briefQuestionsFilter)")!
            }
            
        case .BriefQuestionsRequest:
            let questionIdsString = apiCallParameter as! String
            url = URL(string: "\(apiRoot)\(apiVersion)/questions/\(questionIdsString)?order=desc&sort=activity&site=stackoverflow&key=\(applicationKey)&filter=\(briefQuestionsFilter)")!
            
        case .FullQuestionRequest:
            let questionId = apiCallParameter as! Int
            url = URL(string: "\(apiRoot)\(apiVersion)/questions/\(questionId)?site=stackoverflow&key=\(applicationKey)&filter=\(fullQuestionsFilter)")!
            
        case .UserRequest:
            let userId = apiCallParameter as! Int
            url = URL(string: "\(apiRoot)\(apiVersion)/users/\(userId)?site=stackoverflow&key=\(applicationKey)&filter=\(userFilter)")!
            
        case .MyAccountRequest:
            let accessToken = apiCallParameter as! String
            url = URL(string: "\(apiRoot)\(apiVersion)/me?site=stackoverflow&access_token=\(accessToken)&key=\(applicationKey)&filter=\(userFilter)")!
            
        case .LogOutRequest:
            let accessToken = apiCallParameter as! String
            url = URL(string: "\(apiRoot)\(apiVersion)/apps/\(accessToken)/de-authenticate?key=\(applicationKey)")!
            
        case .ValidateAccessTokenRequest:
            let accessToken = apiCallParameter as! String
            url = URL(string: "\(apiRoot)\(apiVersion)/access-tokens/\(accessToken)?key=\(applicationKey)&filter=\(accessTokenInfoFilter)")!
            
        case .GetUserQuestions:
            if let apiCallParameters = apiCallParameters {
                let userId = apiCallParameter as! Int
                url = URL(string:"\(apiRoot)\(apiVersion)/users/\(userId)/questions?&pagesize=\(apiCallParameters.pageSize)&page=\(apiCallParameters.currentPage)&order=desc&sort=votes&site=stackoverflow&key=\(applicationKey)&filter=\(userQuestionsFilter)")!
            }
            
        case .GetUserAnswers:
            if let apiCallParameters = apiCallParameters {
                let userId = apiCallParameter as! Int
                url = URL(string:"\(apiRoot)\(apiVersion)/users/\(userId)/answers?pagesize=\(apiCallParameters.pageSize)&page=\(apiCallParameters.currentPage)&order=desc&sort=activity&site=stackoverflow&key=\(applicationKey)&filter=\(userAnswersFilter)")!
            }
            
        case .GetMyQuestions:
            if let apiCallParameters = apiCallParameters {
                let accessToken = apiCallParameter as! String
                url = URL(string:"\(apiRoot)\(apiVersion)/me/questions?access_token=\(accessToken)&pagesize=\(apiCallParameters.pageSize)&page=\(apiCallParameters.currentPage)&order=desc&sort=activity&site=stackoverflow&key=\(applicationKey)&filter=\(userQuestionsFilter)")!
            }
            
        case .GetMyAnswers:
            if let apiCallParameters = apiCallParameters {
                let accessToken = apiCallParameter as! String
                url = URL(string:"\(apiRoot)\(apiVersion)/me/answers?access_token=\(accessToken)&pagesize=\(apiCallParameters.pageSize)&page=\(apiCallParameters.currentPage)&order=desc&sort=activity&site=stackoverflow&key=\(applicationKey)&filter=\(userAnswersFilter)")!
            }
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
