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
    private let collapsedCommentsCount = 3
    
    // MARK: - Question Data properties
    
    var questionId = -1
    var answerIdToScrollTo = -1
    var sectionToScrollTo = -1
    var dispalyCommentsCount = -1
    var question : IntermediateQuestion?
    var questionMO : SavedQuestionMO?
    var profileImages : [Int : UIImage] = [Int : UIImage]()
    var isCommentsInSectionCollapsed = [Bool]()
    
    // MARK: - Auxiliary properties
    
    var isDataFromStorage = false
    var questionAndAnswerContentWidth : CGFloat = 0 // Used for correct resizing and positioning images in question and answer UITextViews
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "LoadingQuestionData", attributes: [], target: nil)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        tableView.backgroundView = activityIndicatorView
        
        configureTableView()
        
        questionAndAnswerContentWidth = self.view.frame.size.width - 16 // 16 = 8 units margin on the left + 8 units margin on the right of the UItextView containing answer or question body
        
        if isDataFromStorage == false {
            loadQuestionDataFromWeb()
        } else {
            loadQuestionDataFromDatabase()
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidDisappear(_ animated: Bool)
    {
        super.viewDidDisappear(animated)
        
        ProfileImagesStorage.profileImages.removeAll()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Configuration methods
    
    fileprivate func loadQuestionDataFromWeb()
    {
        if question != nil {
            return
        }
        
        activityIndicatorView.startAnimating()
        
        APICallHelper.APICall(request: APIRequestType.FullQuestionRequest, apiCallParameter: self.questionId, apiCallParameters: nil) { [weak self] (apiWrapperResult : APIResponseWrapper<Question>?) in
            
            guard let closureSelf = self else { return }
            
            guard let questionCodable = apiWrapperResult?.items?[0] else {
                return
            }
            
            closureSelf.question = IntermediateQuestion(question: questionCodable, contentWidth: closureSelf.questionAndAnswerContentWidth)
            closureSelf.question?.answers?.sort(by: {$0.score > $1.score})
            closureSelf.isCommentsInSectionCollapsed.append(true)
            
            if let answers = closureSelf.question?.answers {
                closureSelf.isCommentsInSectionCollapsed.append(contentsOf: [Bool](repeating: true, count: answers.count))
                
                if closureSelf.answerIdToScrollTo != -1, let sectionToScrollTo = closureSelf.question?.answers?.index(where: {$0.answerId == closureSelf.answerIdToScrollTo}) {
                    closureSelf.sectionToScrollTo = sectionToScrollTo + 1 // An answer with specified answerIdToScrollTo might be, for example, at the index 0 in answers array, but in the tableview all answer sections indices = answer index in array + 1 since 0 section is reserved for question
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let indexPath = IndexPath(row: NSNotFound, section: closureSelf.sectionToScrollTo)
                        closureSelf.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
            
            closureSelf.tableView.reloadData()
            closureSelf.activityIndicatorView.stopAnimating()
        }
    }
    
    func loadQuestionDataFromDatabase()
    {
        activityIndicatorView.startAnimating()
        
        dispatchQueue.async {
            OperationQueue.main.addOperation() {
                if let questionMO = self.questionMO {
                    self.question = IntermediateQuestion(question: questionMO, contentWidth: self.questionAndAnswerContentWidth)
                    self.isCommentsInSectionCollapsed.append(true)
                    
                    if let answersCount = self.question?.answers?.count {
                        self.isCommentsInSectionCollapsed.append(contentsOf: [Bool](repeating: true, count: answersCount))
                    }
                }
                
                self.activityIndicatorView.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func loadProfileImages()
    {
        var imageUrlDictionary = [Int : String]()
        
        if let url = question?.owner?.profileImage, let userId = question?.owner?.userId {
            imageUrlDictionary[userId] = url
        }
        
        if let answers = question?.answers {
            for answer in answers {
                if let url = answer.owner?.profileImage, let userId = answer.owner?.userId {
                    imageUrlDictionary[userId] = url
                }
            }
        }
        
        for (userId, url) in imageUrlDictionary {
            if let url = URL(string: url) {
                LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                    guard let sSelf = self else { return }
                    sSelf.profileImages[userId] = image
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
        let commentCount = getCommentsCount(section: section)
        
        if commentCount > collapsedCommentsCount {
            if isCommentsInSectionCollapsed[section] == true {
                return collapsedCommentsCount + 1 // Amount of collapsed comments by default + "Load more comments" cell
            } else {
                return commentCount + 1 // All comments + "Hide Comments" cell
            }
        } else {
            return commentCount
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0 {
            guard let questionView = tableView.dequeueReusableHeaderFooterView(withIdentifier: questionHeaderIdentifier) as? QuestionView else { return nil }

            if let question = self.question {
                questionView.authorAndDateView.authorNamePressedDelegate = self
                questionView.tagPressedDelegate = self
                questionView.initializeQuestionView(with: question, profileImages[question.owner?.userId ?? -1], isDataFromStorage: isDataFromStorage)
            }
        
            return questionView
        } else {
            guard let answerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: answerHeaderIdentifier) as? AnswerView else { return nil }
            
            if let answer = question?.answers?[section - 1] {
                answerView.authorAndDateView.authorNamePressedDelegate = self
                answerView.initializeAnswerView(with: answer, profileImages[answer.owner?.userId ?? -1])
            }
            
            return answerView
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // Last row in sections should always contain "Load more comments"/"Hide comments" cell
        if ((isCommentsInSectionCollapsed[indexPath.section] == true && indexPath.row == collapsedCommentsCount) || indexPath.row == getCommentsCount(section: indexPath.section)) {
            let commentsCount = getCommentsCount(section: indexPath.section)
            
            let uncastedCell = tableView.dequeueReusableCell(withIdentifier: "CollapseExpandCommentsCell", for: indexPath)
            
            guard let collapseExpandCell = uncastedCell as? CollapseExpandCommentsTableViewCell else {
                print("Unable to deque CollapseExpandCommentsCell")
                return uncastedCell
            }
            
            collapseExpandCell.initCell(collapsedCommentsCount: commentsCount, section: indexPath.section, isCollapsed: isCommentsInSectionCollapsed[indexPath.section], collapseExpandCommentsDelegate: self)
            
            return collapseExpandCell
            
        } else {
            let comment = getComment(indexPath: indexPath)
            
            let uncastedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            
            guard let commentCell = uncastedCell as? CommentTableViewCell else {
                print("Unable to deque CollapseExpandCommentsCell")
                return uncastedCell
            }
            
            commentCell.authorNamePressedDelegate = self
            
            commentCell.initializeCommentCell(comment)
            
            return commentCell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
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
                userProfileController.profilePicture = profileImages[userId]
            }
        }
        
        if let searchController = segue.destination as? SearchViewController {
            guard let tagText = sender as? String else {
                return
            }
            
            searchController.searchQuery = tagText
        }
    }
    
    // MARK: - Methods
    
    fileprivate func getCommentsCount(section: Int) -> Int
    {
        var commentsCount = 0
        
        if section == 0 {
            commentsCount = question?.comments?.count ?? 0
        } else {
            commentsCount = question?.answers?[section - 1].comments?.count ?? 0
        }
        
        return commentsCount
    }
    
    fileprivate func getComment(indexPath: IndexPath) -> IntermediateComment
    {
        var commentToInit : IntermediateComment!
        
        if indexPath.section == 0 {
            guard let comment = question?.comments?[indexPath.row] else {
                print("Failed to get comment model for question")
                exit(0)
            }
            
            commentToInit = comment
        } else {
            guard let comment = question?.answers?[indexPath.section - 1].comments?[indexPath.row] else {
                print("Failed to get comment model for answer")
                exit(0)
            }
            
            commentToInit = comment
        }
        
        return commentToInit
    }
}

// MARK: - AuthorNamePressedProtocol, TagButtonPressedProtocol, CollapseExpandCommentsProtocol

extension QuestionTableViewController : AuthorNamePressedProtocol, TagButtonPressedProtocol, CollapseExpandCommentsProtocol
{
    func collapseComments(in section: Int, commentsCount: Int, _ sender: UIButton)
    {
        isCommentsInSectionCollapsed[section] = !isCommentsInSectionCollapsed[section]
        
        if isCommentsInSectionCollapsed[section] == true {
            sender.setAttributedTitle(NSAttributedString(string: "Show \(commentsCount - 3) more"), for: .normal)
            
            var indexPathsToRemove : [IndexPath] = [IndexPath]()
            
            for i in 4...commentsCount {
                indexPathsToRemove.append(IndexPath(row: i, section: section))
            }
            
            tableView.beginUpdates()
                tableView.deleteRows(at: indexPathsToRemove, with: .automatic)
            tableView.endUpdates()
            
            tableView.scrollToRow(at: IndexPath(row: 3, section: section), at: .bottom, animated: true)
            
        } else {
            sender.setAttributedTitle(NSAttributedString(string: "Hide comments"), for: .normal)
            
            var indexPathsToInsert : [IndexPath] = [IndexPath]()
            
            for i in tableView.numberOfRows(inSection: section)...commentsCount {
                indexPathsToInsert.append(IndexPath(row: i, section: section))
            }
            
            tableView.beginUpdates()
                tableView.insertRows(at: indexPathsToInsert, with: .automatic)
                tableView.reloadRows(at: [IndexPath(row: 3, section: section)], with: .none)
            tableView.endUpdates()
            
            tableView.scrollToRow(at: IndexPath(row: 3, section: section), at: .bottom, animated: true)
        }
    }
    
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
}
