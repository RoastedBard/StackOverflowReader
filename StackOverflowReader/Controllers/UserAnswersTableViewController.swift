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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        tableView.backgroundView = activityIndicatorView
        
        getUserAnswers()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return briefQuestions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == briefQuestions.count - 1, briefQuestions.count != 0 {
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
    
    fileprivate func getUserAnswers()
    {
        let userId = getUserId()
        
        DispatchQueue.global(qos: .userInitiated).async {
            APICallHelper.APICall(request: APIRequestType.GetUserAnswers, apiCallParameter: userId){ (apiWrapperResult : APIResponseWrapper<UserAnswer>?) in
                
                if apiWrapperResult?.items?.count == 0 {
                    self.isNothingFound = true
                } else {
                    self.isNothingFound = false
                }
                
                guard let userAnswers = apiWrapperResult?.items else {
                    return
                }
                
                self.userAnswers = userAnswers
                
                var questionIdsString = ""
                
                for (index, userAnswer) in userAnswers.enumerated() {
                    if index != userAnswers.count - 1 {
                        questionIdsString += "\(userAnswer.questionId);"
                    } else {
                        questionIdsString += "\(userAnswer.questionId)"
                    }
                }
                
                print(questionIdsString)
                
                APICallHelper.APICall(request: APIRequestType.BriefQuestionsRequest, apiCallParameter: questionIdsString){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                    
                    self.questionsTotal = apiWrapperResult?.total ?? 0
                    
                    if apiWrapperResult?.items?.count == 0 {
                        self.isNothingFound = true
                    } else {
                        self.isNothingFound = false
                    }
                    
                    guard let questions = apiWrapperResult?.items else {
                        print("Failed to get questions containing user answers")
                        return
                    }
                    
                    for question in questions {
                        self.briefQuestions.append(IntermediateBriefQuestion(question))
                    }
                    
                    self.briefQuestions.sort(by: {$0.score > $1.score})
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPoint.zero, animated: true)
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
    
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
}
