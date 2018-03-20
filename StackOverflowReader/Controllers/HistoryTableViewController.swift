//
//  HistoryTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/20/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

struct SearchHistory
{
    var searchQuery : String = ""
    var visitedQuestions : [IntermediateBriefQuestion] = [IntermediateBriefQuestion]()
}

class HistoryTableViewController: UITableViewController
{
    // MARK: - Data
    
    var history : [SearchHistory]?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return history?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if history == nil {
            return 1
        }
        
        return history?[section].visitedQuestions.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if history == nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoHistoryCell", for: indexPath)

            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as? SOPostCell else {
                print("Failed to deque cell in SearchViewController")
                exit(0)
            }
            
            cell.authorNamePressedDelegate = self
            
            guard let briefQuestions = history?[indexPath.section].visitedQuestions else {
                exit(0)
            }
            
            cell.initCell(question: briefQuestions[indexPath.row])
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return "History"
    }
}

extension HistoryTableViewController : AuthorNamePressedProtocol, TagButtonPressedProtocol
{
    func tagButtonPressed(tagText: String)
    {
        performSegue(withIdentifier: "SearchByTagSegue", sender: tagText)
    }
    
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let uvc = segue.destination as? UserViewController {
            let userId = sender as? Int
            
            uvc.userId = userId ?? -1
            //uvc.profilePicture = profileImages[userId ?? -1]
        }
    }
}
