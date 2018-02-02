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
    
    var question : Question?
    var questionAttributedData : QuestionAttributedData?
    
    var questionAndAnswerContentWidth : CGFloat = 0 // Used for correct resizing and positioning images in question and answer UITextViews
    
    var attributedQuestionData : QuestionAttributedData?
    var attributedAnswers : [CommonAttributedData?] = [CommonAttributedData?]()
    var attributedComments : [Int : [CommonAttributedData?]] = [Int : [CommonAttributedData?]]()
    
    // MARK: - Configuration
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        configureTableView()
        
        questionAndAnswerContentWidth = self.view.frame.size.width - 16 // 16 = 8 units margin on the left + 8 units margin on the right of the UItextView containing answer or question body
        
        initializeAttributedData()
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
    
    fileprivate func initializeAttributedData()
    {
        questionAttributedData = QuestionAttributedData(title: question!.title, body: question!.body, authorName: question?.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth)
        
        if let questionComments = question?.comments {
            
            attributedComments[0] = [CommonAttributedData]()
            
            for comment in questionComments {
                attributedComments[0]!.append(CommonAttributedData(body: comment.body, authorName: comment.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth))
            }
        }
        
        if let answers = question?.answers {
            attributedAnswers = Array(repeating: nil, count: answers.count)

            for (index, answer) in answers.enumerated() {
                if let comments = answer.comments{
                    attributedComments[index + 1] = Array(repeating: nil, count: comments.count) // "index + 1" because index=0 reserved for question comments
                }
            }
        }
    }
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return question?.answers?.count ?? 1
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
            questionView.delegate = self

            questionView.initializeQuestionView(question!, screenWidth: questionAndAnswerContentWidth, questionAttributedData!)
            
            return questionView
        } else {
            guard let answerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: answerHeaderIdentifier) as? AnswerView else { return nil }

            let answer = question!.answers![section - 1]

            answerView.owner = answer.owner
            answerView.delegate = self

            if attributedAnswers.count > 0 {
                if let answerAttrData = attributedAnswers[section - 1] {
                    answerView.initializeAnswerView(answer, screenWidth: questionAndAnswerContentWidth, answerAttrData)
                } else {
                    attributedAnswers[section - 1] = CommonAttributedData(body: answer.body, authorName: answer.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth)

                    answerView.initializeAnswerView(answer, screenWidth: questionAndAnswerContentWidth, attributedAnswers[section - 1]!)
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
        
        cell.delegate = self
        
        if indexPath.section == 0 {
            
            if let comments = attributedComments[0] {
                if let comment = comments[indexPath.row] {
                    cell.initializeCommentCell(question!.comments![indexPath.row], comment)
                }
            }
            
        } else {
            
            if let comments = attributedComments[indexPath.section] {
                let commentModel = question!.answers![indexPath.section - 1].comments![indexPath.row]
                
                if let comment = comments[indexPath.row] {
                    cell.initializeCommentCell(commentModel, comment)
                }
                else {
                    attributedComments[indexPath.section]![indexPath.row] = CommonAttributedData(body: commentModel.body, authorName: commentModel.owner?.displayName ?? "NAME_NOT_SPECIFIED", contentWidth: questionAndAnswerContentWidth)
                }
            }
            
        }
        
        return cell
    }
}

extension QuestionTableViewController : AuthorNamePressedProtocol
{
    func authorNamePressed(_ owner : ShallowUser?)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: owner)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let owner = sender as? ShallowUser
        
        if let uvc = segue.destination as? UserViewController {
            uvc.shallowUser = owner
        }
    }
}
