//
//  ViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/18/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit
import Alamofire
import CodableAlamofire

struct QuestionList : Codable
{
    var items : [Question]
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource
{
    var questionList : QuestionList?
    var questions : [Question]?
    
    @IBOutlet var searchSortButtons: [UIButton]!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    weak var currentSortOptionButton: UIButton!
    
    var currentPage : Int = 1
    var searchQuery : String = ""
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        currentSortOptionButton = searchSortButtons[0]
        
        searchBar.delegate = self
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func expandSortDropDown(_ sender: UIButton)
    {
        for button in searchSortButtons {
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
        }
    }

    @IBAction func sortOptionSelected(_ sender: UIButton)
    {
        sortByButton.setTitle("Sort by \(sender.titleLabel!.text!)", for: .normal)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if searchBar.text!.isEmpty {
            return
        }
        
        searchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "%20")
        
        if self.questionList != nil {
            self.questionList!.items.removeAll()
        }
        
        let url = URL(string: "https://api.stackexchange.com/2.2/search/advanced?page=\(currentPage)&order=desc&pagesize=30&sort=votes&q=\(searchQuery)&site=stackoverflow&filter=!FH4kGNU5*mKF.Xy99s-h6.(B15HzE8P6_uK6oJxTFlxuApd(gSND2.n3pMWnC4BiNn5g-dR1")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                
                self.questionList = try! decoder.decode(QuestionList.self, from: data)
                self.questions = self.questionList?.items
                
                self.questionList?.items.removeAll()
                
                DispatchQueue.main.async {
                    self.searchResultsTableView.reloadData()
                }
            }
        }
        
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if questions != nil {
            return questions!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as! SOPostCell
        
        if let questions = questions {
            cell.initCell(question: questions[indexPath.item], index: indexPath.item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = questions!.count - 1
        
        if indexPath.row == lastElement {
            currentPage += 1
            
            let url = URL(string: "https://api.stackexchange.com/2.2/search/advanced?page=\(currentPage)&order=desc&pagesize=30&sort=votes&q=\(searchQuery)&site=stackoverflow&filter=!FH4kGNU5*mKF.Xy99s-h6.(B15HzE8P6_uK6oJxTFlxuApd(gSND2.n3pMWnC4BiNn5g-dR1")!
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    let decoder = JSONDecoder()
                    
                    self.questionList = try! decoder.decode(QuestionList.self, from: data)
                    if self.questions == nil {
                        self.questions = self.questionList!.items
                    } else {
                        self.questions! += self.questionList!.items
                    }
                    
                    self.questionList?.items.removeAll()
                    
                    DispatchQueue.main.async {
                        self.searchResultsTableView.reloadData()
                    }
                }
            }
            
            task.resume()
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is QuestionTableViewController
        {
            let questionController = segue.destination as? QuestionTableViewController
            let i = (sender as? SOPostCell)!.questionIndex
            questionController?.question = questions![i]
        }
    }
}

