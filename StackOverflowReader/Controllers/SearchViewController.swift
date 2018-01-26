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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentSortOptionButton = searchSortButtons[0]
        
        searchBar.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
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
        QuestionsContainer.questions?.removeAll()
        
        APICallHelper.currentPage = 1
        
        APICallHelper.searchAPICall(searchQuery, updateUIClosure: {
            // TODO: Scroll to the top
            self.searchResultsTableView.reloadData()
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if searchBar.text!.isEmpty {
            return
        }
        
        searchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "%20")
        
        reloadSearchResults()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if QuestionsContainer.questions != nil {
            return QuestionsContainer.questions!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as! SOPostCell
        
        if let questions = QuestionsContainer.questions {
            cell.initCell(question: questions[indexPath.item], index: indexPath.item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = QuestionsContainer.questions!.count - 1
        
        if indexPath.row == lastElement {
            APICallHelper.currentPage += 1
            
            APICallHelper.searchAPICall(searchQuery, updateUIClosure: {
                self.searchResultsTableView.reloadData()
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is QuestionTableViewController
        {
            let questionController = segue.destination as? QuestionTableViewController
            let i = (sender as? SOPostCell)!.questionIndex
            questionController?.question = QuestionsContainer.questions![i]
        }
    }
}

