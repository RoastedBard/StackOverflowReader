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

class Qs : Codable {
    var title : String?
    var view_count : Int?
}

class SearchViewController: UIViewController {
    
    var questionList : [Qs]?
    
    @IBOutlet var searchSortButtons: [UIButton]!
    @IBOutlet weak var sortByButton: UIButton!
    
    weak var currentSortOptionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let border = CALayer()
        border.backgroundColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: sortByButton.frame.size.height - 1, width: sortByButton.frame.size.width, height: 1)
        sortByButton.layer.addSublayer(border)
        
        currentSortOptionButton = searchSortButtons[0]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func expandSortDropDown(_ sender: UIButton) {
        for button in searchSortButtons {
            UIView.animate(withDuration: 0.3, animations: {
                button.isHidden = !button.isHidden
                self.view.layoutIfNeeded()
            })
            
        }
    }

    @IBAction func sortOptionSelected(_ sender: UIButton) {
        sortByButton.setTitle("Sort by \(sender.titleLabel!.text!)", for: .normal)
    }
    
}

