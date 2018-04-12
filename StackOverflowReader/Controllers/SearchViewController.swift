//
//  ViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/18/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource
{
    // MARK: - UI Elements
    
    @IBOutlet var searchSortButtons: [UIButton]!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    weak var currentSortOptionButton: UIButton!
    var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    var searchQuery = ""
    var briefQuestions = [IntermediateBriefQuestion]()
    var apiCallWrapper : APIResponseWrapper<BriefQuestion>?
    var isNothingFound = false
    var questionsTotal = 0
    var apiCallParameters = APICallParameters()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchResultsTableView.tableFooterView = UIView()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        searchResultsTableView.backgroundView = activityIndicatorView
        
        currentSortOptionButton = searchSortButtons[0]
        
        apiCallParameters.pageSize = UserSettings.searchPageSize
        
        self.hideKeyboardWhenTappedAround()
        
        searchBar.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        
        // Remove "Saved Posts" tab bar item if not authorized
        if AuthorizationManager.isAuthorized == false {
            let savedQuestionsIndex = 2 // Search = 0; History = 1; Saved Questions = 2; More = 3
            
            guard var viewControllers = self.tabBarController?.viewControllers else { return }
            
            viewControllers.remove(at: savedQuestionsIndex)
            
            self.tabBarController?.viewControllers = viewControllers
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Sort dropdown
    
    fileprivate func animateSortOptionsDropdown()
    {
        for button in searchSortButtons {
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Actions
    
    @IBAction func expandSortDropDown(_ sender: UIButton)
    {
        animateSortOptionsDropdown()
    }

    @IBAction func sortOptionSelected(_ sender: UIButton)
    {
        sortByButton.setTitle("Sort by \(sender.titleLabel!.text!)", for: .normal)
        sortSearchResults()
    }
    
    @IBAction func sortByActivityButtonPressed(_ sender: UIButton)
    {
        apiCallParameters.sort = .activity
    }
    
    @IBAction func sortByVotesButtonPressed(_ sender: UIButton)
    {
        apiCallParameters.sort = .votes
    }
    
    @IBAction func sortByCreationButtonPressed(_ sender: UIButton)
    {
        apiCallParameters.sort = .creation
    }
    
    @IBAction func sortByRelevanceButtonPressed(_ sender: UIButton)
    {
        apiCallParameters.sort = .relevance
    }
    
    // MARK: - Methods
    
    func sortSearchResults()
    {
        animateSortOptionsDropdown()
        
        if searchQuery == "" {
            return
        }
        
        reloadSearchResults()
    }
    
    func reloadSearchResults()
    {
        if apiCallWrapper?.items != nil, apiCallWrapper?.items?.count != 0 {
            apiCallWrapper!.items!.removeAll()
        }
        
        briefQuestions.removeAll()
        
        self.searchResultsTableView.reloadData()
        
        apiCallParameters.currentPage = 1
        
        activityIndicatorView.startAnimating()
        sortByButton.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            APICallHelper.APICall(request: APIRequestType.SearchBriefQuestionsRequest, apiCallParameter: self.searchQuery, apiCallParameters: self.apiCallParameters){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                    
                    if apiWrapperResult?.items?.count == 0 {
                        self.isNothingFound = true
                    } else {
                        self.isNothingFound = false
                    }
                    
                    self.apiCallWrapper = apiWrapperResult
                    
                    guard let questions = self.apiCallWrapper?.items else {
                        return
                    }
                    
                    self.questionsTotal = apiWrapperResult?.total ?? 0
                    
                    for question in questions {
                        self.briefQuestions.append(IntermediateBriefQuestion(question))
                    }
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.searchResultsTableView.reloadData()
                    self.searchResultsTableView.setContentOffset(CGPoint.zero, animated: true)
                    
                    self.sortByButton.isEnabled = true
                }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if searchBar.text!.isEmpty {
            return
        }

        searchQuery = searchBar.text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""

        searchBar.endEditing(true)

        reloadSearchResults()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isNothingFound == true {
            return 1
        }
        
        if briefQuestions.count != 0 {
            return briefQuestions.count + 1 // + 1 cell with "Load More" button
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == briefQuestions.count, briefQuestions.count != 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreTableViewCell else {
                print("Failed to deque load more cell in SearchViewController")
                exit(0)
            }
            
            cell.loadMoreDelegate = self
            
            cell.loadMoreButton.setTitle("Load \(apiCallParameters.pageSize) more (\(questionsTotal) total)", for: .normal)
            
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
    
    @IBAction func unwindToSearchController(segue:UIStoryboardSegue)
    {
        if searchQuery != "" {
            searchBar.text = searchQuery
            reloadSearchResults()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowQuestionSeque"{
            if let qtvc = segue.destination as? QuestionTableViewController {
                
                guard let pressedCell = sender as? BriefQuestionTableViewCell else {
                    return
                }
                
                guard let indexPath = self.searchResultsTableView.indexPath(for: pressedCell) else {
                    return
                }
                
                if let historyItem = SearchHistoryManager.searchHistory.first(where: {$0.searchQuery == searchQuery}) {
                    historyItem.visitedQuestions.append(briefQuestions[indexPath.row])
                } else {
                    let historyItem = SearchHistoryItem(searchQuery: searchQuery)
                    historyItem.visitedQuestions.append(briefQuestions[indexPath.row])
                    SearchHistoryManager.searchHistory.append(historyItem)
                }
                
                qtvc.questionId = pressedCell.questionId
                
                qtvc.isDataFromStorage = false
            }
        }
        
        if segue.identifier == "ShowUserInfo" {
            if let userTabBarController = segue.destination as? UserProfileTabBarController {
                
                guard let userId = sender as? Int else {
                    print("Unable to get userId")
                    return
                }
                
                //userProfileController.userId = userId
                userTabBarController.userId = userId
            }
        }
    }
}

// MARK: - AuthorNamePressedProtocol, LoadMoreQuestionsProtocol

extension SearchViewController : AuthorNamePressedProtocol, LoadMoreQuestionsProtocol
{
    func loadMoreQuestions(sender : UIButton, activityIndicatorView : UIActivityIndicatorView)
    {
        sender.isHidden = true
        activityIndicatorView.startAnimating()
        
        sortByButton.isEnabled = false
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.apiCallParameters.currentPage += 1
            
            APICallHelper.APICall(request: APIRequestType.SearchBriefQuestionsRequest, apiCallParameter: self.searchQuery, apiCallParameters: self.apiCallParameters){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                if let newQuestions = apiWrapperResult?.items {
                    self.apiCallWrapper?.items?.append(contentsOf: newQuestions)
                    
                    for question in newQuestions {
                        self.briefQuestions.append(IntermediateBriefQuestion(question))
                    }
                }
                
                activityIndicatorView.stopAnimating()
                
                sender.isHidden = false
                
                self.searchResultsTableView.reloadData()
                
                self.questionsTotal -= self.apiCallParameters.pageSize
                
                self.sortByButton.isEnabled = true
            }
        }
    }
    
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


