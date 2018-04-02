//
//  TableViewExtension.swift
//  StackOverflowReader
//
//  Created by Ruslan Lezhnin on 3/29/18.
//  Copyright © 2018 chisw. All rights reserved.
//

import Foundation
import UIKit

extension UITableView
{
    func scrollToBottom()
    {
        scrollToRow(at: IndexPath(row: numberOfRows(inSection: numberOfSections-1)-1, section: numberOfSections-1),
                    at: .bottom, animated: true)
    }
}
