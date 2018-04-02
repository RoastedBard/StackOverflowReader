//
//  HistoryTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController
{
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if SearchHistoryManager.searchHistory.count == 0 {
            return 1
        } else {
            return SearchHistoryManager.searchHistory.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if SearchHistoryManager.searchHistory.count == 0 {
            return 1
        }
        
        return SearchHistoryManager.searchHistory[section].visitedQuestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if SearchHistoryManager.searchHistory.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoHistoryCell", for: indexPath)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath) as? SearchHistoryTableViewCell else {
                print("Failed to deque cell in SearchViewController")
                exit(0)
            }
            
            cell.authorNamePressedDelegate = self
            
            let briefQuestions = SearchHistoryManager.searchHistory[indexPath.section].visitedQuestions
            
            cell.initCell(question: briefQuestions[indexPath.row])
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if SearchHistoryManager.searchHistory.count == 0 {
            return "History"
        } else {
            return SearchHistoryManager.searchHistory[section].searchQuery.removingPercentEncoding
        }
    }
}

// MARK: - AuthorNamePressedProtocol

extension HistoryTableViewController : AuthorNamePressedProtocol
{
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Show User Info segue
        
        if segue.identifier == "ShowUserInfo" {
            if let userTabBarController = segue.destination as? UserProfileTabBarController {
                guard let userProfileController = userTabBarController.viewControllers![0] as? UserViewController else {
                    print("Unable to get UserViewController")
                    return
                }
                
                guard let userId = sender as? Int else {
                    print("Unable to get userId")
                    return
                }
                
                userTabBarController.userId = userId
            }
        }
        
        // Show Question segue
        
        if segue.identifier == "ShowQuestionSeque" {
            if let qtvc = segue.destination as? QuestionTableViewController {
                
                guard let pressedCell = sender as? SearchHistoryTableViewCell else {
                    return
                }
                
                qtvc.questionId = pressedCell.questionId
                
                qtvc.isDataFromStorage = false
            }
        }
    }
}
