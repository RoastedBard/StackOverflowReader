//
//  SavedPostsTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/27/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import CoreData

class SavedPostsTableViewController: UITableViewController
{
    // MARK: - Properties
    
    var briefQuestions : [IntermediateBriefQuestion] = [IntermediateBriefQuestion]()
    var briefQuestionsMO : [BriefQuestionMO] = [BriefQuestionMO]()
    
    // MARK: - Core Data properties
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
    var dataController : DataController!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        refreshControl?.addTarget(self, action: #selector(refreshSavedPosts(_:)), for: .valueChanged)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        dataController = appDelegate.dataController

        fetchDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    
        /* TODO: Hiding back button and displaying title not working
         
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationItem.backBarButtonItem = nil
        self.navigationController?.navigationItem.title = "Saved Posts"
        */
        
        if dataController.isNeedUpdate == true {
            fetchDatabase()
            
            tableView.reloadData()
            
            dataController.isNeedUpdate = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        // self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Configuration
    
    func fetchDatabase()
    {
        guard let authorizedUserId = AuthorizationManager.authorizedUser?.userId else {
            return
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BriefQuestion")
        
        let dateSort = NSSortDescriptor(key: "dateSaved", ascending: true)
        
        request.predicate = NSPredicate(format: "detailQuestion.loggedUser.userId = %d", authorizedUserId)
        request.sortDescriptors = [dateSort]
        
        briefQuestions.removeAll()
        briefQuestionsMO.removeAll()
        
        do {
            briefQuestionsMO = try dataController.managedObjectContext.fetch(request) as! [BriefQuestionMO]
            
            for questionMO in briefQuestionsMO {
                briefQuestions.append(IntermediateBriefQuestion(questionMO))
            }
        } catch {
            fatalError("Failed to fetch: \(error)")
        }
    }
    
    func initializeFetchedResultsController()
    {
        guard let authorizedUserId = AuthorizationManager.authorizedUser?.userId else {
            return
        }
        
        let managedContext = dataController.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BriefQuestion")
        
        let dateSort = NSSortDescriptor(key: "dateSaved", ascending: true)
        
        request.predicate = NSPredicate(format: "detailQuestion.loggedUser.userId = %d", authorizedUserId)
        request.sortDescriptors = [dateSort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    // MARK: - Actions
    
    @objc private func refreshSavedPosts(_ sender: Any)
    {
        fetchDatabase()
        
        tableView.reloadData()
        
        refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return briefQuestions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BriefQuestionTableViewCell", for: indexPath) as? BriefQuestionTableViewCell else {
            fatalError("Wrong cell type dequeued")
        }
        
        cell.initCell(question: briefQuestions[indexPath.row])
        
        return cell
    }
    
    // This method handles row deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            
            let briefQuestionMO = briefQuestionsMO[indexPath.row]
            
            guard let savedQuestion = briefQuestionMO.detailQuestion else {
                print("Can't get detail question")
                exit(0)
            }
            
            dataController.managedObjectContext.delete(savedQuestion)
            
            briefQuestions.remove(at: indexPath.row)
            briefQuestionsMO.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .right)
            
            dataController.saveContext()
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowQuestionSeque" {
            if let qtvc = segue.destination as? QuestionTableViewController {
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    return
                }
                
                qtvc.isDataFromStorage = true
                
                let questionAndAnswerContentWidth = self.view.frame.size.width - 16 // 16 = 8 units margin on the left + 8 units margin on the right of the UItextView containing answer or question body
                
                guard let savedQuestionMO = briefQuestionsMO[indexPath.row].detailQuestion else {
                    return
                }
                
                qtvc.questionMO = savedQuestionMO
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
