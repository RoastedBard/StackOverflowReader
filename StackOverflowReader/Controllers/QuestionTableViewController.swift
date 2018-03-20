//
//  QuestionTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit
import CoreData

class QuestionTableViewController: UITableViewController
{
    // MARK: - Constant properties
    private let cellIdentifier = "CommentCell"
    private let questionHeaderIdentifier = "QuestionHeaderIdentifier"
    private let answerHeaderIdentifier = "AnswerHeaderIdentifier"
    
    // MARK: - Question Data properties
    var questionId : Int = -1
    var question : IntermediateQuestion?
    var profileImages : [Int : UIImage] = [Int : UIImage]()
    
    // MARK: - Auxiliary properties
    var isDataFromStorage = false
    var questionAndAnswerContentWidth : CGFloat = 0 // Used for correct resizing and positioning images in question and answer UITextViews
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "LoadingQuestionData", attributes: [], target: nil)
    
    // MARK: - Core data properties
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    var indexPath : IndexPath = IndexPath()
    
    // MARK: - Configuration methods
    fileprivate func loadQuestionDataFromWeb()
    {
        if question == nil {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                OperationQueue.main.addOperation() {
                    APICallHelper.APICall(request: APIRequestType.FullQuestionRequest, apiCallParameter: self.questionId){ (apiWrapperResult : APIResponseWrapper<Question>?) in
                        if let questionCodable = apiWrapperResult?.items![0] {
                            self.question = IntermediateQuestion(question: questionCodable, contentWidth: self.questionAndAnswerContentWidth)
                            self.question?.answers?.sort(by: {$0.score > $1.score})
                            self.loadProfileImages()
                        }
                        
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func loadQuestionDataFromDatabase()
    {
        activityIndicatorView.startAnimating()
        
        dispatchQueue.async {
            OperationQueue.main.addOperation() {
                guard let briefQuestion = self.fetchedResultsController?.object(at: self.indexPath) as? BriefQuestionMO else {
                    print("Unable to get object at preapre for segue")
                    return
                }
                
                guard let fullQuestion = briefQuestion.detailQuestion else {
                    print("Unable to get fullQuestion at preapre for segue")
                    return
                }
                
                self.question = IntermediateQuestion(question: fullQuestion, contentWidth: self.questionAndAnswerContentWidth)
                self.question?.answers?.sort(by: {$0.score > $1.score})
                
                self.question?.comments?.sort(by: {$0.creationDate < $1.creationDate})
                
                if let answers = self.question?.answers {
                    for answer in answers {
                        answer.comments?.sort(by: {$0.creationDate < $1.creationDate})
                    }
                }
                
                self.loadProfileImages()
                
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func loadProfileImages()
    {
        // Downloading and saving question author profile picture
        if let userImageLink = question?.owner?.profileImage, let userId = question?.owner?.userId {
            if let url = URL(string: userImageLink) {
                LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                    guard let sSelf = self else { return }
                    sSelf.profileImages[userId] = image
                }
            }
        }
        
        if let answers = question?.answers {
            for answer in answers {
                if let userImageLink = answer.owner?.profileImage, let userId = answer.owner?.userId {
                    if let url = URL(string: userImageLink) {
                        LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                            guard let sSelf = self else { return }
                            sSelf.profileImages[userId] = image
                        }
                    }
                }
            }
        }
    }
    
    private func configureTableView()
    {
        tableView.estimatedSectionHeaderHeight = 44.0
        
        let questionNib = UINib.init(nibName: String(describing: QuestionView.self), bundle: nil)
        let answerNib = UINib.init(nibName: String(describing: AnswerView.self), bundle: nil)
        
        tableView.register(questionNib, forHeaderFooterViewReuseIdentifier: questionHeaderIdentifier)
        tableView.register(answerNib, forHeaderFooterViewReuseIdentifier: answerHeaderIdentifier)
    }
    
    // MARK : - Tableview loading methods
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillAppear(animated)
        
        if isDataFromStorage == false {
            loadQuestionDataFromWeb()
        } else {
            loadQuestionDataFromDatabase()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        tableView.backgroundView = activityIndicatorView
        
        configureTableView()
        
        questionAndAnswerContentWidth = self.view.frame.size.width - 16 // 16 = 8 units margin on the left + 8 units margin on the right of the UItextView containing answer or question body
    }

    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if question == nil{
            return 0
        }
        
        if let answerCount = question?.answers?.count {
            return answerCount + 1 // answers + 1 question
        } else {
            return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            return question?.comments?.count ?? 0
        } else {
            return question?.answers?[section - 1].comments?.count ?? 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0 {
            guard let questionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: questionHeaderIdentifier) as? QuestionView else { return nil }
           
            questionView.authorNamePressedDelegate = self
            questionView.tagPressedDelegate = self
            
            if let question = self.question {
                questionView.initializeQuestionView(question, profileImages[question.owner?.userId ?? -1], isDataFromStorage: isDataFromStorage)
            }
        
            return questionView
        } else {
            guard let answerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: answerHeaderIdentifier) as? AnswerView else { return nil }
            
            if let answer = question?.answers?[section - 1] {
                answerView.authorNamePressedDelegate = self
                
                answerView.initializeAnswerView(answer, profileImages[answer.owner?.userId ?? -1])
            }
            
            return answerView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CommentTableViewCell
        
        cell.authorNamePressedDelegate = self
        
        if indexPath.section == 0 {
            guard let comment = question?.comments?[indexPath.row] else {
                print("Failed to get comment model for question")
                exit(0)
            }
            
            cell.initializeCommentCell(comment)
            
        } else {
            guard let comment = question?.answers?[indexPath.section - 1].comments?[indexPath.row] else {
                print("Failed to get comment model for answer")
                exit(0)
            }

            cell.initializeCommentCell(comment)
        }
        return cell
    }
}

extension QuestionTableViewController : AuthorNamePressedProtocol, TagButtonPressedProtocol
{
    func tagButtonPressed(tagText: String)
    {
        performSegue(withIdentifier: "SearchByTagSegue", sender: tagText)
    }
    
    func authorNamePressed(userId id : Int)
    {
        if !isDataFromStorage {
            performSegue(withIdentifier: "ShowUserInfo", sender: id)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let uvc = segue.destination as? UserViewController {
            let userId = sender as? Int
            
            uvc.userId = userId ?? -1
            uvc.profilePicture = profileImages[userId ?? -1]
        }
        
        if let searchController = segue.destination as? SearchViewController {
            guard let tagText = sender as? String else {
                return
            }
            
            searchController.searchQuery = tagText
        }
    }
}
