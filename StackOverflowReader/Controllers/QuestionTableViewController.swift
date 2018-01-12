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
    var question : Question?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if question?.answers != nil {
            return question!.answers!.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0 {
            if question?.comments != nil {
                return question!.comments!.count
            } else {
                return 0
            }
        } else {
            if question?.answers?[section - 1].comments != nil{
                return question!.answers![section - 1].comments!.count
            } else {
                return 0
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        if section == 0 {
            let questionView = Bundle.main.loadNibNamed("QuestionView", owner: self, options: nil)?.first as! QuestionView
            
            questionView.owner = question?.owner
            
            questionView.delegate = self
            
            questionView.initializeQuestionView(question!)
            
            return questionView
        } else {
            let answerView = Bundle.main.loadNibNamed("AnswerView", owner: self, options: nil)?.first as! AnswerView
            
            let answer = question!.answers![section - 1]
            
            answerView.owner = question!.answers![section - 1].owner
            
            answerView.delegate = self
            
            answerView.initializeAnswerView(answer)
            
            return answerView
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentTableViewCell
        
        cell.delegate = self
        
        if indexPath.section == 0 {
            if let comments = question?.comments {
                cell.initializeCommentCell(comments[indexPath.item])
            }
        } else {
            if let comments = question?.answers?[indexPath.section - 1].comments {
                cell.initializeCommentCell(comments[indexPath.item])
            }
        }
        return cell
    }
}

extension QuestionTableViewController : AuthorNamePressedProtocol
{
    func authorNamePressed(_ owner : User?)
    {
        performSegue(withIdentifier: "ShowUserInfo", sender: owner)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let owner = sender as? User
        
        if let uvc = segue.destination as? UserViewController {
            uvc.user = owner
        }
    }
}
