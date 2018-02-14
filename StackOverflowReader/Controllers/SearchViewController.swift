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
    @IBOutlet var searchSortButtons: [UIButton]!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    weak var currentSortOptionButton: UIButton!
    
    var searchQuery : String = ""
    
    var cellAttributedData : [CommonAttributedData?] = [CommonAttributedData?]()
    
    var apiCallWrapper : APIResponseWrapper<BriefQuestion>?
    
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "LoadingQuestionData", attributes: [], target: nil)
    
    var isNothingFound = false
    
    override func viewDidLoad()
    {
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        searchResultsTableView.backgroundView = activityIndicatorView
        
        currentSortOptionButton = searchSortButtons[0]
        
        searchBar.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func animateSortOptionsDropdown() {
        for button in searchSortButtons {
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @IBAction func expandSortDropDown(_ sender: UIButton)
    {
        animateSortOptionsDropdown()
    }

    @IBAction func sortOptionSelected(_ sender: UIButton)
    {
        sortByButton.setTitle("Sort by \(sender.titleLabel!.text!)", for: .normal)
        sortSearchResults()
    }
    
    func sortSearchResults()
    {
        animateSortOptionsDropdown()
        
        if searchQuery == ""{
            return
        }
        
        reloadSearchResults()
    }
    
    @IBAction func sortByActivityButtonPressed(_ sender: UIButton)
    {
        APICallHelper.sort = .activity
    }
    
    @IBAction func sortByVotesButtonPressed(_ sender: UIButton)
    {
        APICallHelper.sort = .votes
    }
    
    @IBAction func sortByCreationButtonPressed(_ sender: UIButton)
    {
        APICallHelper.sort = .creation
    }
    
    @IBAction func sortByRelevanceButtonPressed(_ sender: UIButton)
    {
        APICallHelper.sort = .relevance
    }
    
    func reloadSearchResults()
    {
        if apiCallWrapper?.items != nil, apiCallWrapper?.items?.count != 0 {
            apiCallWrapper!.items!.removeAll()
        }
        
        cellAttributedData.removeAll()
        
        self.searchResultsTableView.reloadData()
        
        APICallHelper.currentPage = 1
        
        activityIndicatorView.startAnimating()
        
        dispatchQueue.async {
            OperationQueue.main.addOperation() {
                APICallHelper.APICall(request: APIRequestType.BriefQuestionsRequest, apiCallParameter: self.searchQuery){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                    
                    if apiWrapperResult?.items?.count == 0 {
                        self.isNothingFound = true
                    } else {
                        self.isNothingFound = false
                    }
                    
                    self.apiCallWrapper = apiWrapperResult
                    
                    for question in self.apiCallWrapper!.items! {
                        let attrData : CommonAttributedData = CommonAttributedData()
                        
                        attrData.attributedBodyString = question.title.htmlAttributedString
                        attrData.attributedAuthorNameString = question.owner?.displayName?.htmlAttributedString
                        
                        self.cellAttributedData.append(attrData)
                    }
                    
                    self.activityIndicatorView.stopAnimating()
                    
                    self.searchResultsTableView.reloadData()
                    self.searchResultsTableView.setContentOffset(CGPoint.zero, animated: true)
                }
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isNothingFound == true {
            return 1
        }
        
        return apiCallWrapper?.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if isNothingFound == true {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NothingFoundCell", for: indexPath)
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as! SOPostCell
            
            cell.authorNamePressedDelegate = self
            
            if let questions = apiCallWrapper?.items {
                cell.initCell(question: questions[indexPath.row], attributedData: cellAttributedData[indexPath.row]!)
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        var lastElement = -1
        
        if let elementCount = apiCallWrapper?.items?.count {
            lastElement = elementCount - 1
        }
        
        if indexPath.row == lastElement {
            APICallHelper.currentPage += 1
            
            APICallHelper.APICall(request: APIRequestType.BriefQuestionsRequest, apiCallParameter: self.searchQuery){ (apiWrapperResult : APIResponseWrapper<BriefQuestion>?) in
                if let newQuestions = apiWrapperResult?.items {
                    self.apiCallWrapper?.items?.append(contentsOf: newQuestions)
                    
                    for question in newQuestions {
                        let attrData : CommonAttributedData = CommonAttributedData()
                        
                        attrData.attributedBodyString = question.title.htmlAttributedString
                        attrData.attributedAuthorNameString = question.owner?.displayName?.htmlAttributedString
                        
                        self.cellAttributedData.append(attrData)
                    }
                }
                
                self.searchResultsTableView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowQuestionSeque"{
            if let qtvc = segue.destination as? QuestionTableViewController {
                let questionId = (sender as? SOPostCell)!.questionId
                qtvc.questionId = questionId
            }
        }
        
        if segue.identifier == "ShowUserInfo" {
            if let uvc = segue.destination as? UserViewController {
                let userId = sender as? Int
                uvc.userId = userId ?? -1
            }
        }
    }
}

extension SearchViewController : AuthorNamePressedProtocol
{
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
}
