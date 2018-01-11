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

struct QuestionList : Codable {
    var items : [Question]
}

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var questionList : QuestionList?
    
    @IBOutlet var searchSortButtons: [UIButton]!
    @IBOutlet weak var sortByButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultsTableView: UITableView!
    
    weak var currentSortOptionButton: UIButton!
    
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
        let searchQuery = searchBar.text!.replacingOccurrences(of: " ", with: "%20")
        
        if self.questionList != nil {
            self.questionList!.items.removeAll()
        }
        
        let url = URL(string: "https://api.stackexchange.com/2.2/search/advanced?order=desc&sort=relevance&q=\(searchQuery)&site=stackoverflow&filter=!3vHg3*UddE8Rou9YzZ_cPH*zk6qEqkEAowsKjb6Vds12Pkmyf3mA)m8v83LYFwH")!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                let decoder = JSONDecoder()
                
                self.questionList = try! decoder.decode(QuestionList.self, from: data)
                
                DispatchQueue.main.async {
                    self.searchResultsTableView.reloadData()
                }
            }
        }
        
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if questionList != nil {
            return questionList!.items.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SOPostCell", for: indexPath) as! SOPostCell
        
        if let questions = questionList {
            cell.initCell(question: questions.items[indexPath.item], index: indexPath.item)
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is QuestionTableViewController
        {
            let qvc = segue.destination as? QuestionTableViewController
            let i = (sender as? SOPostCell)!.questionIndex
            qvc?.question = questionList!.items[i]
        }
    }
}

