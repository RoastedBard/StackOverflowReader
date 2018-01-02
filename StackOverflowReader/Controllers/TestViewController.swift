//
//  TestViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/28/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit

class TestViewController: UITableViewController {
    
    var question : Question?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionCell = UINib(nibName: "QuestionTableViewCell", bundle: nil)
        self.tableView.register(questionCell, forCellReuseIdentifier: "QuestionCell")
        
        let answerCell = UINib(nibName: "AnswerTableViewCell", bundle: nil)
        self.tableView.register(answerCell, forCellReuseIdentifier: "AnswerCell")
        
        question = Question()
        
        // ANSWER ONE
        let answerOne = Answer()
        
        answerOne.author = User()
        answerOne.author?.userName = "Peter Combee"
        
        answerOne.votes = 24
        
        answerOne.body =
        """
        I uses this in one of our projects, maby its usefull to you
        
        import UIKit
        
        class RegisterPageView: UIView {
        
        class func instanceFromNib() -> RegisterPageView {
        return UINib(nibName: "RegisterPageView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! RegisterPageView
        }
        }
        """
        answerOne.date = Date()
        
        // ANSWER TWO
        let answerTwo = Answer()
        
        answerTwo.author = User()
        answerTwo.author?.userName = "Morgan Wilde"
        
        answerTwo.votes = 12
        
        answerTwo.body =
        """
        Using Swift 3.0
        
        let viewFromNib: UIView? = Bundle.main.loadNibNamed("NibName", owner: nil, options: nil)?.first
        """
        answerTwo.date = Date()
        
        //QUESTION COMMENT 1
        var qCommentOne = Comment()
        
        qCommentOne.author = User()
        qCommentOne.author?.userName = "lukaivicev"
        qCommentOne.body = "Is your XIB file really named \"nil\"?"
        qCommentOne.date = Date()
        qCommentOne.votes = 0
        
        //QUESTION COMMENT 2
        var qCommentTwo = Comment()
        
        qCommentTwo.author = User()
        qCommentTwo.author?.userName = "Jimmy lemieux"
        qCommentTwo.body = "Yes it is named nib"
        qCommentTwo.date = Date()
        qCommentTwo.votes = 0
        
        //QUESTION COMMENT 3
        var qCommentThree = Comment()
        
        qCommentThree.author = User()
        qCommentThree.author?.userName = "Pradeep K"
        qCommentThree.body = "Seems to work fine...which specific line is it crashing?"
        qCommentThree.date = Date()
        qCommentThree.votes = 0
        
        //ANSWER COMMENT ONE
        var aCommentOne = Comment()
        
        aCommentOne.author = User()
        aCommentOne.author?.userName = "m_katsifarakis"
        aCommentOne.body = "I like this approach. In my case, .xib files contain only one view of the current class and guard let view = nib.instantiate(withOwner: nil, options: nil).last crashed, since .last returned nil. For some reason, guard let view = nib.instantiate(withOwner: nil, options: nil)[0] works great though. Just change .last to [0]"
        aCommentOne.date = Date()
        aCommentOne.votes = 2
        
        // QUESTION
        question!.title = "Loading a XIB file to a UIView Swift"
        question!.body =
        """
        I am trying to load my XIB file into a UIView but I am having some trouble. I have the required override functions but they seem to be crashing. Saying this error, warning could not load any Objective-C class information. This will significantly reduce the quality of type information available. I was wondering if someone could show me how to properly load the XIB file into a UIView
        
        import UIKit
        
        class Widget: UIView {
            
            let view = UIView()
            
            override init(frame: CGRect) {
                super.init(frame: frame)
                
                //call function
                
                loadNib()
                
            }
            
            required init?(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)
                
                loadNib()
                
                //fatalError("init(coder:) has not been implemented")
            }
            
            func loadNib() {
                let bundle = NSBundle(forClass: self.dynamicType)
                let nib = UINib(nibName: "nib", bundle: bundle)
                let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
                view.frame = bounds
                view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
                self.addSubview(view);
            }
        }
        """
        
        question?.author = User()
        question?.author?.userName = "Jimmy lemieux"
        
        question?.date = Date()
        question?.votes = 9
        
        answerTwo.comments = [aCommentOne]
        
        question?.answers = [answerOne, answerTwo]
        
        question?.comments = [qCommentOne, qCommentTwo, qCommentThree]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (question?.answers?.count)! + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.cellForRow(at: indexPath) != nil {
            return tableView.cellForRow(at: indexPath)!
        }
        
        if indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionTableViewCell
            cell.initCell(question: question!)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerTableViewCell
            
            if let answer = question?.answers![indexPath.item - 1] {
                cell.initCell(answer: answer)
            }
            
            return cell
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
