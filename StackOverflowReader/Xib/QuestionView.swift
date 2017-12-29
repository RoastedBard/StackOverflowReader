//
//  QuestionView.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 12/29/17.
//  Copyright © 2017 chisw. All rights reserved.
//

import UIKit

class QuestionView: UIView {

//    @IBOutlet weak var commentsStackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
//        let commentCell = Bundle.main.loadNibNamed("CommentView", owner:
//            self, options: nil)?.first as? CommentView
//        
//        let commentCell1 = Bundle.main.loadNibNamed("CommentView", owner:
//            self, options: nil)?.first as? CommentView
//        
//        let commentCell2 = Bundle.main.loadNibNamed("CommentView", owner:
//            self, options: nil)?.first as? CommentView
//        
//        let commentCell3 = Bundle.main.loadNibNamed("CommentView", owner:
//            self, options: nil)?.first as? CommentView
//        
//        commentsStackView.addArrangedSubview(commentCell!)
//        commentsStackView.addArrangedSubview(commentCell1!)
//        commentsStackView.addArrangedSubview(commentCell2!)
//        commentsStackView.addArrangedSubview(commentCell3!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
