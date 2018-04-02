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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        tableView.backgroundView = activityIndicatorView
        
        if isLoggedUser() == true {
            getUserQuestions(requestType: .GetMyQuestions, userId: nil)
        } else {
            getUserQuestions(requestType: .GetUserQuestions, userId: getUserId())
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
            return briefQuestions.count + 1 // + 1 cell with "Load More" button
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == briefQuestions.count, briefQuestions.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreTableViewCell else {
                print("Failed to deque load more cell in SearchViewController")
                exit(0)
            }
            
            cell.loadMoreDelegate = self
            
            cell.loadMoreButton.setTitle("Load \(APICallHelper.pageSize) more (\(questionsTotal) total)", for: .normal)
            
            return cell
        }
        
        if isNothingFound == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFoundCell", for: indexPath)
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "BriefQuestionTableViewCell", for: indexPath) as? BriefQuestionTableViewCell else {
                print("Failed to deque cell in SearchViewController")
                exit(0)
            }
            
            cell.authorNamePressedDelegate = nil
            
            cell.initCell(question: briefQuestions[indexPath.row])
            
            return cell
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
    
    fileprivate func processAPICallResult(apiWrapperResult : APIResponseWrapper<BriefQuestion>?)
    {
        if apiWrapperResult?.items?.count == 0 || apiWrapperResult?.items == nil {
            isNothingFound = true
        } else {
            isNothingFound = false
        }
        
        guard let questions = apiWrapperResult?.items else {
            return
        }
        
        questionsTotal = apiWrapperResult?.total ?? 0
        
        for question in questions {
            briefQuestions.append(IntermediateBriefQuestion(question))
        }
        
        activityIndicatorView.stopAnimating()
        
        tableView.reloadData()
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    fileprivate func getUserQuestions(requestType: APIRequestType, userId: Int?)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            APICallHelper.APICall(request: requestType, apiCallParameter: userId){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                self.processAPICallResult(apiWrapperResult: apiWrapperResult)
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
        
        let userId = getUserId()
        
        DispatchQueue.global(qos: .userInitiated).async {
            APICallHelper.currentPage += 1
            
            APICallHelper.APICall(request: APIRequestType.GetUserQuestions, apiCallParameter: userId){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                if let newQuestions = apiWrapperResult?.items {
                    for question in newQuestions {
                        self.briefQuestions.append(IntermediateBriefQuestion(question))
                    }
                }
                
                activityIndicatorView.stopAnimating()
                
                sender.isHidden = false
                
                self.tableView.reloadData()
                
                self.questionsTotal -= APICallHelper.pageSize
            }
        }
    }
}
