//
//  TestViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/28/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    
   
    
    @IBOutlet weak var postStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionView = Bundle.main.loadNibNamed("QuestionView", owner:
            self, options: nil)?.first as? QuestionView
        
        postStackView.addSubview(questionView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
