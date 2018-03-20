//
//  TagsTestViewController.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/16/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class TagsTestViewController: UIViewController
{
    let tags : [String] = ["additional","func","UIViewController","swift","Any","before","super","UIKit","segue", "systemgroup", "effective", "settings", "VectorKit", "ActivationLoggingTaskedOffByDA", "System", "HangTracerEnabled", "framework"]
    
    @IBOutlet weak var tagCollectionView: UIView!
    
    @IBOutlet weak var tagCollectionViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttonHeight : CGFloat = 16
        let horizontalSpacing : CGFloat = 8
        let verticalSpacing : CGFloat = 8
        
        var nextOrigin : CGPoint = CGPoint.zero
        
        for tag in tags {
            let tagView = UIButton(frame: CGRect(x: nextOrigin.x, y: nextOrigin.y, width: 0, height: 0))
            tagView.setTitle(tag, for: .normal)
            tagView.sizeToFit()
            tagView.frame.size.height = buttonHeight
            tagView.setTitleColor(.black, for: .normal)
            tagView.backgroundColor = .cyan
            
            if nextOrigin.x + tagView.frame.width > tagCollectionView.frame.width {
                nextOrigin.x = 0.0
                nextOrigin.y += buttonHeight + verticalSpacing
                
                tagCollectionViewHeightConstraint.constant += buttonHeight + verticalSpacing
                
                tagView.frame.origin = nextOrigin
            }
            
            tagCollectionView.addSubview(tagView)
            
            nextOrigin.x = tagView.frame.maxX + horizontalSpacing
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addTagButtonPressed(_ sender: UIButton)
    {
//        if tags.isEmpty { return }
//
//        let index = Int(arc4random_uniform(UInt32(tags.count)))
//
//        let tagView = UIButton(frame: CGRect(x: nextOrigin.x, y: nextOrigin.y, width: 0, height: 0))
//        tagView.setTitle(tags[index], for: .normal)
//        tagView.sizeToFit()
//        tagView.frame.size.height = self.buttonHeight
//        tagView.setTitleColor(.black, for: .normal)
//        tagView.backgroundColor = .cyan
//
//        if nextOrigin.x + tagView.frame.width > tagCollectionView.frame.width {
//            nextOrigin.x = 0.0
//            nextOrigin.y += buttonHeight + verticalSpacing
//
//            tagCollectionViewHeightConstraint.constant += buttonHeight + verticalSpacing
//
//            tagView.frame.origin = nextOrigin
//        }
//
//        tagCollectionView.addSubview(tagView)
//
//        nextOrigin.x = tagView.frame.maxX + horizontalSpacing
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
