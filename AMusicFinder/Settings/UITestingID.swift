//
//  UITestingID.swift
//  AMusicFinder
//
//  Created by Kaka on 26/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

/**
 Setting IDs for UI Testing.
 */
struct UITestingID {
    /// main tableView
    static let tableID = "table"
    static let searchBarID = "Music to Search"
    
    static func cellID(row: Int) -> String {
        return String(format: "cell_%d", row)
    }
}
