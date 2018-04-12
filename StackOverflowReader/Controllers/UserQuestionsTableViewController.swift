//
//  UserQuestionsTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/29/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class UserQuestionsTableViewController: UITableViewController
{
    // MARK: - UI Elements
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var briefQuestions : [IntermediateBriefQuestion] = [IntermediateBriefQuestion]()
    var isNothingFound = false
    var questionsTotal = 0
    var questionsLeft = 0
    var apiCallParameters = APICallParameters()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        tableView.backgroundView = activityIndicatorView
        
        activityIndicatorView.startAnimating()
        
        var requestType : APIRequestType = .GetMyQuestions
        var apiCallParameter : Any? = AuthorizationManager.accessToken
        
        if isLoggedUser() == false {
            requestType = .GetUserQuestions
            apiCallParameter = getUserId()
        }
        
        getUserQuestions(requestType: requestType, apiCallParameter: apiCallParameter) {
            self.activityIndicatorView.stopAnimating()
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isNothingFound == true {
            return 1
        }
        
        if briefQuestions.count != 0 {
            return questionsLeft != 0 ? briefQuestions.count + 1 : briefQuestions.count // + 1 cell with "Load More" button
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == briefQuestions.count, questionsLeft != 0 {
            
            let uncastedCell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath)
            
            guard let loadMoreCell = uncastedCell as? LoadMoreTableViewCell else {
                print("Failed to deque load more cell in SearchViewController")
                return uncastedCell
            }
            
            loadMoreCell.loadMoreDelegate = self
            
            if questionsLeft == 0 {
                loadMoreCell.loadMoreButton.isHidden = true
                loadMoreCell.loadMoreActivityIndicator.isHidden = true
            } else {
                loadMoreCell.loadMoreButton.setTitle("Load \(apiCallParameters.pageSize) more (\(questionsLeft) left)", for: .normal)
            }
            return loadMoreCell
        }
        
        if isNothingFound == true {
            let nothingFoundCell = tableView.dequeueReusableCell(withIdentifier: "NothingFoundCell", for: indexPath)
            
            return nothingFoundCell
        } else {
            let uncastedCell = tableView.dequeueReusableCell(withIdentifier: "BriefQuestionTableViewCell", for: indexPath)
            
            guard let briefQuestionCell = uncastedCell as? BriefQuestionTableViewCell else {
                print("Failed to deque cell in SearchViewController")
                return uncastedCell
            }
            
            briefQuestionCell.authorNamePressedDelegate = nil
            
            briefQuestionCell.initCell(question: briefQuestions[indexPath.row])
            
            return briefQuestionCell
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowQuestionSeque" {
            if let qtvc = segue.destination as? QuestionTableViewController {
                
                guard let pressedCell = sender as? BriefQuestionTableViewCell else {
                    return
                }
                
                guard let indexPath = self.tableView.indexPath(for: pressedCell) else {
                    return
                }
                
                if let historyItem = SearchHistoryManager.searchHistory.first(where: {$0.searchQuery == "Visited From Users"}) {
                    historyItem.visitedQuestions.append(briefQuestions[indexPath.row])
                } else {
                    let historyItem = SearchHistoryItem(searchQuery: "Visited From Users")
                    historyItem.visitedQuestions.append(briefQuestions[indexPath.row])
                    SearchHistoryManager.searchHistory.append(historyItem)
                }
                
                qtvc.questionId = pressedCell.questionId
                
                qtvc.isDataFromStorage = false
            }
        }
    }
    
    // MARK: - Methods
    
    fileprivate func getUserId() -> Int
    {
        guard let tabBarController = self.tabBarController as? UserProfileTabBarController else {
            print("Failed to get tabBarController")
            return -1
        }
        
        return tabBarController.userId
    }
    
    fileprivate func isLoggedUser() -> Bool
    {
        guard let tabBarController = self.tabBarController as? UserProfileTabBarController else {
            print("Failed to get tabBarController")
            return false
        }
        
        return tabBarController.isLoggedUser
    }
    
    fileprivate func processAPICallResult(apiWrapperResult : APIResponseWrapper<BriefQuestion>?, uiCompletion: @escaping () -> Void)
    {
        if apiWrapperResult?.items?.count == 0 || apiWrapperResult?.items == nil {
            isNothingFound = true
        } else {
            isNothingFound = false
        }
        
        guard let questions = apiWrapperResult?.items else {
            return
        }
        
        for question in questions {
            briefQuestions.append(IntermediateBriefQuestion(question))
        }
        
        print("briefQuestions.count = \(briefQuestions.count)")
        
        if questionsTotal == 0 {
            questionsTotal = apiWrapperResult?.total ?? 0
            print("questionsTotal = \(questionsTotal)")
            questionsLeft = questionsTotal
        }
        
        apiCallParameters.currentPage += 1
        
        if questionsLeft < apiCallParameters.pageSize {
            apiCallParameters.pageSize = questionsLeft
            questionsLeft = 0
        } else {
            questionsLeft -= apiCallParameters.pageSize
            
            if questionsLeft < apiCallParameters.pageSize {
                apiCallParameters.pageSize = questionsLeft
            }
        }
        
        uiCompletion()
    }
    
    fileprivate func getUserQuestions(requestType: APIRequestType, apiCallParameter: Any?, completion: @escaping () -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            APICallHelper.APICall(request: requestType, apiCallParameter: apiCallParameter, apiCallParameters: self.apiCallParameters) { (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                self.processAPICallResult(apiWrapperResult: apiWrapperResult) {
                    completion()
                }
            }
        }
    }
}

// MARK: - LoadMoreQuestionsProtocol

extension UserQuestionsTableViewController : LoadMoreQuestionsProtocol
{
    func loadMoreQuestions(sender : UIButton, activityIndicatorView : UIActivityIndicatorView)
    {
        sender.isHidden = true
        activityIndicatorView.startAnimating()
        
        var requestType : APIRequestType = .GetMyQuestions
        var apiCallParameter : Any? = AuthorizationManager.accessToken
        
        if isLoggedUser() == false {
            requestType = .GetUserQuestions
            apiCallParameter = getUserId()
        }
        
        getUserQuestions(requestType: requestType, apiCallParameter: apiCallParameter) {
            activityIndicatorView.stopAnimating()
            sender.isHidden = false
            self.tableView.reloadData()
        }
    }
}
