//
//  QuestionTableViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 1/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class QuestionTableViewController: UITableViewController {

    var question : Question?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionCell = UINib(nibName: "QuestionTableViewCell", bundle: nil)
        self.tableView.register(questionCell, forCellReuseIdentifier: "QuestionCell")

        let answerCell = UINib(nibName: "AnswerTableViewCell", bundle: nil)
        self.tableView.register(answerCell, forCellReuseIdentifier: "AnswerCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if question?.answers == nil{
                return 0
            } else {
                return question!.answers!.count
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            if question?.answers == nil{
                return "No answers"
            } else {
                return "\(question!.answers!.count) Answers"
            }
        } else {
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionTableViewCell
            
            cell.initCell(question: question!)

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerTableViewCell
            
            if cell.isInitialized == false {
                if let answer = question?.answers![indexPath.item] {
                    cell.initCell(answer: answer)
                }
            }
            
            return cell
        }
    }
}
