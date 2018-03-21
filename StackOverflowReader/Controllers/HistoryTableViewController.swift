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
    // MARK: - Core Data properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
    
    let dispatchQueue = DispatchQueue(label: "LoadingSearchHistoryData", attributes: [], target: nil)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        dispatchQueue.async {
            OperationQueue.main.addOperation() {
                self.initializeFetchedResultsController()
                
                if let loggedUser = self.fetchedResultsController.fetchedObjects as? [LoggedUserMO] {
                    
                    if let searchHistoryMO = loggedUser[0].history?.allObjects as? [SearchHistoryItemMO] {
                        
                        for searchHistoryItemMO in searchHistoryMO {
                            let searchHistoryItem = SearchHistoryItem(searchQuery: searchHistoryItemMO.searchQuery ?? "")
                            
                            if let briefQuestionsMO = searchHistoryItemMO.questions?.allObjects as? [BriefQuestionMO] {
                                
                                for briefQuestionMO in briefQuestionsMO {
                                    let briefQuestion = IntermediateBriefQuestion(briefQuestionMO)
                                    searchHistoryItem.visitedQuestions.append(briefQuestion)
                                }
                            }
                            
                            SearchHistoryManager.searchHistory.append(searchHistoryItem)
                        }
                    }
                }
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Fetched results controller configuration
    
    func initializeFetchedResultsController()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        guard let authorizedUserId = AuthorizationManager.authorizedUser?.userId else {
            return
        }
        
        let managedContext = appDelegate.dataController.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "LoggedUser")
        
        request.predicate = NSPredicate(format: "userId = %d", authorizedUserId)
        
        let userIdSort = NSSortDescriptor(key: "userId", ascending: true)
        
        request.sortDescriptors = [userIdSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as? SOPostCell else {
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
            return SearchHistoryManager.searchHistory[section].searchQuery
        }
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
