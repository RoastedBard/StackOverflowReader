//
//  CollapseExpandCommentsTableViewCell.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 4/3/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import UIKit

class CollapseExpandCommentsTableViewCell: UITableViewCell
{
    // MARK: - UI Elements
    
    @IBOutlet weak var expandCollapseCommentsButton: UIButton!
    
    // MARK: - Properties
    
    var section = -1
    var collapsedCommentsCount = 0
    
    // MARK: - Delegate
    
    var delegate : CollapseExpandCommentsProtocol?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
    }
    
    // MARK: - Actions
    
    @IBAction func expandCollapseCommentsButtonPressed(_ sender: UIButton)
    {
        if section != -1 {
            delegate?.collapseComments(in: section, commentsCount: collapsedCommentsCount, sender)
        }
    }
    
    // MARK: - Methods
    
    func initCell(collapsedCommentsCount: Int, section: Int, isCollapsed: Bool, collapseExpandCommentsDelegate: CollapseExpandCommentsProtocol?)
    {
        delegate = collapseExpandCommentsDelegate
        
        self.section = section
        self.collapsedCommentsCount = collapsedCommentsCount
        
        if isCollapsed == true {
            expandCollapseCommentsButton.setAttributedTitle(NSAttributedString(string: "Show \(collapsedCommentsCount - 3) more"), for: .normal)
        } else {
            expandCollapseCommentsButton.setAttributedTitle(NSAttributedString(string: "Hide comments"), for: .normal)
        }
    }
}
