//
//  Errors.swift
//  AMusicFinder
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

/**
 The error defined for searching.
 */
enum SearchError: Error {
    /// term key is not provided
    case termKeyNotSet
}
