//
//  UserAnswersTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/29/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class UserAnswersTableViewController: UITableViewController
{
    // MARK: - UI Elements
    
    var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var briefQuestions : [IntermediateBriefQuestion] = [IntermediateBriefQuestion]()
    var userAnswers : [UserAnswer] = [UserAnswer]()
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

        var requestType : APIRequestType = .GetMyAnswers
        var apiCallParameter : Any? = AuthorizationManager.accessToken
        
        if isLoggedUser() == false {
            requestType = .GetUserAnswers
            apiCallParameter = getUserId()
        }
        
        activityIndicatorView.startAnimating()
        
        getUserAnswers(requestType: requestType, apiCallParameter: apiCallParameter) {
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
        if indexPath.row == briefQuestions.count, briefQuestions.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreTableViewCell else {
                print("Failed to deque load more cell in SearchViewController")
                exit(0)
            }
            
            cell.loadMoreDelegate = self
            
            cell.loadMoreButton.setTitle("Load \(apiCallParameters.pageSize) more (\(questionsLeft) left)", for: .normal)
            
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
            
            cell.authorNamePressedDelegate = self
            
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
                
                let questionId = pressedCell.questionId
                
                var answerIdToScrollTo = -1
                
                qtvc.questionId = questionId
                
                for userAnswer in userAnswers {
                    if userAnswer.questionId == questionId {
                        answerIdToScrollTo = userAnswer.answerId
                    }
                }
                
                qtvc.answerIdToScrollTo = answerIdToScrollTo
                
                qtvc.isDataFromStorage = false
            }
        }
        
        if segue.identifier == "ShowUserInfo" {
            if let userTabBarController = segue.destination as? UserProfileTabBarController {
                
                guard let userId = sender as? Int else {
                    print("Unable to get userId")
                    return
                }
                
                userTabBarController.userId = userId
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
    
    fileprivate func getQuestionIds(apiWrapperResult : APIResponseWrapper<UserAnswer>?) -> String?
    {
        if apiWrapperResult?.items?.count == 0 || apiWrapperResult?.items == nil {
            isNothingFound = true
            return nil
        } else {
            isNothingFound = false
        }
        
        guard let userAnswers = apiWrapperResult?.items else {
            return nil
        }
        
        self.userAnswers.append(contentsOf: userAnswers)
        
        var questionIdsString = ""
        
        for (index, userAnswer) in userAnswers.enumerated() {
            if index != userAnswers.count - 1 {
                questionIdsString += "\(userAnswer.questionId);"
            } else {
                questionIdsString += "\(userAnswer.questionId)"
            }
        }
        
        if self.questionsTotal == 0 {
            self.questionsTotal = apiWrapperResult?.total ?? 0
            print("questionsTotal = \(self.questionsTotal)")
            self.questionsLeft = self.questionsTotal
        }
        
        self.apiCallParameters.currentPage += 1
        
        if self.questionsLeft < self.apiCallParameters.pageSize {
            self.apiCallParameters.pageSize = self.questionsLeft
            self.questionsLeft = 0
        } else {
            self.questionsLeft -= self.apiCallParameters.pageSize
            
            if self.questionsLeft < self.apiCallParameters.pageSize {
                self.apiCallParameters.pageSize = self.questionsLeft
            }
        }
        
        print(questionIdsString)
        
        return questionIdsString
    }
    
    fileprivate func getQuestionsContainingAnswers(questionIdsString: String, uiCompletion: @escaping () -> Void)
    {
        APICallHelper.APICall(request: APIRequestType.BriefQuestionsRequest, apiCallParameter: questionIdsString, apiCallParameters: apiCallParameters){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
            
            if apiWrapperResult?.items?.count == 0 || apiWrapperResult?.items == nil {
                self.isNothingFound = true
            } else {
                self.isNothingFound = false
            }
            
            guard let questions = apiWrapperResult?.items else {
                return
            }
            
            for question in questions {
                self.briefQuestions.append(IntermediateBriefQuestion(question))
            }
            
            print("briefQuestions.count = \(self.briefQuestions.count)")
            
            uiCompletion()
        }
    }
    
    fileprivate func processAPICallResult(apiWrapperResult : APIResponseWrapper<UserAnswer>?, completion: @escaping () -> Void)
    {
        if let questionIdsString = getQuestionIds(apiWrapperResult: apiWrapperResult) {
            getQuestionsContainingAnswers(questionIdsString: questionIdsString) {
                completion()
            }
        } else {
            completion()
        }
    }
    
    fileprivate func getUserAnswers(requestType: APIRequestType, apiCallParameter: Any?, completion: @escaping () -> Void)
    {
        DispatchQueue.global(qos: .userInitiated).async {
            APICallHelper.APICall(request: requestType, apiCallParameter: apiCallParameter, apiCallParameters: self.apiCallParameters){ (apiWrapperResult : APIResponseWrapper<UserAnswer>?) in
                self.processAPICallResult(apiWrapperResult: apiWrapperResult) {
                    completion()
                }
            }
        }
    }
}

// MARK: - AuthorNamePressedProtocol, LoadMoreQuestionsProtocol

extension UserAnswersTableViewController : AuthorNamePressedProtocol, LoadMoreQuestionsProtocol
{
    func loadMoreQuestions(sender : UIButton, activityIndicatorView : UIActivityIndicatorView)
    {
        sender.isHidden = true
        activityIndicatorView.startAnimating()
        
        var requestType : APIRequestType = .GetMyAnswers
        var apiCallParameter : Any? = AuthorizationManager.accessToken
        
        if isLoggedUser() == false {
            requestType = .GetUserAnswers
            apiCallParameter = getUserId()
        }
        
        activityIndicatorView.startAnimating()
        
        getUserAnswers(requestType: requestType, apiCallParameter: apiCallParameter) {
            self.activityIndicatorView.stopAnimating()
            sender.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
}
