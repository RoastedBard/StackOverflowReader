//
//  QuestionTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class QuestionTableViewController: UITableViewController
{
    // MARK: - Constants
    private let cellIdentifier = "CommentCell"
    private let questionHeaderIdentifier = "QuestionHeaderIdentifier"
    private let answerHeaderIdentifier = "AnswerHeaderIdentifier"
    
    var questionId : Int = -1
    
    var question : Question?
    
    var questionAndAnswerContentWidth : CGFloat = 0 // Used for correct resizing and positioning images in question and answer UITextViews
    
    var activityIndicatorView: UIActivityIndicatorView!
    let dispatchQueue = DispatchQueue(label: "LoadingQuestionData", attributes: [], target: nil)
    
    // MARK: - Cached data
    var attributedQuestionData : QuestionAttributedData?
    var attributedAnswers : [CommonAttributedData?] = [CommonAttributedData?]()
    var attributedComments : [Int : [CommonAttributedData?]] = [Int : [CommonAttributedData?]]()
    
    var profileImages : [Int : UIImage] = [Int : UIImage]()
    
    // MARK: - Configuration
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        tableView.backgroundView = activityIndicatorView
        
        configureTableView()
        
        questionAndAnswerContentWidth = self.view.frame.size.width - 16 // 16 = 8 units margin on the left + 8 units margin on the right of the UItextView containing answer or question body
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        super.viewWillAppear(animated)
        
        if question == nil {
            activityIndicatorView.startAnimating()
            
            dispatchQueue.async {
                OperationQueue.main.addOperation() {
                    APICallHelper.APICall(request: APIRequestType.FullQuestionRequest, apiCallParameter: self.questionId){ (apiWrapperResult : APIResponseWrapper<Question>?) in
                        self.question = apiWrapperResult?.items![0]
                        
                        self.initializeData()
                        
                        self.activityIndicatorView.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
        }
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
    
    private func configureTableView()
    {
        tableView.estimatedSectionHeaderHeight = 44.0
        
        let questionNib = UINib.init(nibName: String(describing: QuestionView.self), bundle: nil)
        let answerNib = UINib.init(nibName: String(describing: AnswerView.self), bundle: nil)
        
        tableView.register(questionNib, forHeaderFooterViewReuseIdentifier: questionHeaderIdentifier)
        tableView.register(answerNib, forHeaderFooterViewReuseIdentifier: answerHeaderIdentifier)
    }
    
    fileprivate func initializeData()
    {
        // Sorting answers in DESC order by score value
        question?.answers?.sort {$0.score > $1.score}
        
        // Converting and caching question data (title, body, author name)
        attributedQuestionData = QuestionAttributedData(title: question!.title, body: question!.body, authorName: question?.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth)
        
        // Converting and caching question comments
        // In attributedComments dictionary, 0 index is reserved for question comments attributed data array
        if let questionComments = question?.comments {

            attributedComments[0] = [CommonAttributedData]()

            for comment in questionComments {
                attributedComments[0]!.append(CommonAttributedData(body: comment.body, authorName: comment.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth, isImageProcessingNeeded: false))
            }
        }
        
        // Downloading and saving question author profile picture
        if let userImageLink = question?.owner?.profileImage, let userId = question?.owner?.userId {
            if let url = URL(string: userImageLink) {
                //downloadImage(from: url, to: userId)
                LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                    guard let sSelf = self else { return }
                    sSelf.profileImages[userId] = image
                }
            }
        }
        
        // Converting and caching answer data
        if let answers = question?.answers {
            
            for (i, answer) in answers.enumerated() {
                // Converting and caching answer body and author name
                attributedAnswers.append(CommonAttributedData(body: answer.body, authorName: answer.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth, isImageProcessingNeeded: true))
                
                let answerIndex = i + 1 // "i + 1" because "i = 0" is reserved for question comments
                
                // Downloading and saving answer author profile picture
                if let userImageLink = answer.owner?.profileImage, let userId = answer.owner?.userId {
                    if let url = URL(string: userImageLink) {
                        //downloadImage(from: url, to: userId)
                        LinkToImageViewHelper.downloadImage(from: url) { [weak self] image in
                            guard let sSelf = self else { return }
                            sSelf.profileImages[userId] = image
                        }
                    }
                }
                
                // Converting and caching answer comments
                if let comments = answer.comments {
                    
                    attributedComments[answerIndex] = [CommonAttributedData]()
                    
                    for comment in comments {
                        attributedComments[answerIndex]?.append(CommonAttributedData(body: comment.body, authorName: comment.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth, isImageProcessingNeeded: false))
                    }
                }
            }
        }
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

            questionView.owner = question?.owner
            questionView.authorNamePressedDelegate = self
            
            if let attrData = attributedQuestionData, let question = question {
                questionView.initializeQuestionView(question, screenWidth: questionAndAnswerContentWidth, attributedData: attrData, profileImages[question.owner?.userId ?? -1])
            }
            
            return questionView
        } else {
            guard let answerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: answerHeaderIdentifier) as? AnswerView else { return nil }

            if let answer = question?.answers?[section - 1] {
                answerView.owner = answer.owner
                answerView.authorNamePressedDelegate = self
                
                if let attrData = attributedAnswers[section - 1] {
                    answerView.initializeAnswerView(answer, screenWidth: questionAndAnswerContentWidth, attributedData: attrData, profileImages[answer.owner?.userId ?? -1])
                }
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
            if let comments = attributedComments[0] {
                if let comment = comments[indexPath.row] {
                    cell.initializeCommentCell(question!.comments![indexPath.row], comment)
                }
            }
        } else {
            if let comments = attributedComments[indexPath.section] {
                let commentModel = question!.answers![indexPath.section - 1].comments![indexPath.row]

                if let attrComment = comments[indexPath.row] {
                    cell.initializeCommentCell(commentModel, attrComment)
                }
            }
        }
        
        return cell
    }
}

extension QuestionTableViewController : AuthorNamePressedProtocol
{
    func authorNamePressed(userId id : Int)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let userId = sender as? Int
        
        if let uvc = segue.destination as? UserViewController {
            uvc.userId = userId ?? -1
            uvc.profilePicture = profileImages[userId ?? -1]
        }
    }
}
