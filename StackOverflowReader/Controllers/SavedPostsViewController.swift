//
//  SavedPostsViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/27/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit
import CoreData

class SavedPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var savedPostsTableView : UITableView!
    
    var questionAndAnswerContentWidth : CGFloat = 0 // Used for correct resizing and positioning images in question and answer UITextViews
    
    var briefQuestions : [IntermediateBriefQuestion] = [IntermediateBriefQuestion]()
    
    let dispatchQueue = DispatchQueue(label: "LoadingSavedQuestionData", attributes: [], target: nil)
    
    // MARK: - Core Data stuff
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>!
    var appDelegate : AppDelegate?
    
    // MARK: - TableView loading methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        savedPostsTableView.allowsMultipleSelectionDuringEditing = false
        
        questionAndAnswerContentWidth = self.view.frame.size.width - 16 // 16 = 8 units margin on the left + 8 units margin on the right of the UItextView containing answer or question body
        
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        savedPostsTableView.delegate = self
        savedPostsTableView.dataSource = self
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        dispatchQueue.async {
            OperationQueue.main.addOperation() {
                self.initializeFetchedResultsController()
                
                if let savedQuestionsMO = self.fetchedResultsController.fetchedObjects as? [BriefQuestionMO] {
                    for savedQuestionMO in savedQuestionsMO {
                        self.briefQuestions.append(IntermediateBriefQuestion(savedQuestionMO))
                    }
                }
                self.savedPostsTableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Configuration
    
    func initializeFetchedResultsController()
    {
        guard let appDelegate = appDelegate else {
            return
        }
        
        guard let authorizedUserId = AuthorizationManager.authorizedUser?.userId else {
            return
        }
        
        let managedContext = appDelegate.dataController.managedObjectContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BriefQuestion")
        
        request.predicate = NSPredicate(format: "detailQuestion.loggedUser.userId = %d", authorizedUserId)
        
        let dateSort = NSSortDescriptor(key: "dateSaved", ascending: true)
        
        request.sortDescriptors = [dateSort]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        savedPostsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
    {
        switch type {
        case .insert:
            savedPostsTableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            savedPostsTableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:
            if let newBriefQuestion = anObject as? BriefQuestionMO {
                briefQuestions.append(IntermediateBriefQuestion(newBriefQuestion))
            }
            
            savedPostsTableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            if let indexPath = indexPath {
                briefQuestions.remove(at: indexPath.row)
            }
            
            savedPostsTableView.deleteRows(at: [indexPath!], with: .right)
        case .update:
            savedPostsTableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            savedPostsTableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {
        savedPostsTableView.endUpdates()
    }

    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return briefQuestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as? SOPostCell else
        {
            fatalError("Wrong cell type dequeued")
        }
        
        if briefQuestions.count != 0 {
            cell.initCell(question: briefQuestions[indexPath.row])
        }
        
        return cell
    }

    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete {
            
            // remove the item from the data model
            guard let object = self.fetchedResultsController?.object(at: indexPath) as? BriefQuestionMO else {
                print("Attempt to configure cell without a managed object")
                exit(0)
            }
            
            guard let savedQuestion = object.detailQuestion else {
                print("Can't get detail question")
                exit(0)
            }
            
            if let appDelegate = appDelegate {
                appDelegate.dataController.managedObjectContext.delete(savedQuestion)
                
                appDelegate.dataController.saveContext()
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowQuestionSeque" {
            if let qtvc = segue.destination as? QuestionTableViewController {
                guard let indexPath = savedPostsTableView.indexPathForSelectedRow else {
                    return
                }
                
                qtvc.isDataFromStorage = true
                qtvc.fetchedResultsController = self.fetchedResultsController
                qtvc.indexPath = indexPath
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
