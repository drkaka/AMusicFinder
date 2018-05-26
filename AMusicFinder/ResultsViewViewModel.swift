//
//  ResultsViewViewModel.swift
//  AMusicFinder
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

/**
 View-Model implementation for ResultsViewController
 */
class ResultsViewViewModel: NSObject, ResultsViewProtocol {
    /// delegate for `ResultViewController`
    weak var delegate: ResultViewDelegate?
    
    /**
     Search music with given search term.
     
     - parameters:
        - term: The count of `String` should > 0.
        - completion: `MusicSearchHandler`. If `term` is empty, directly return `SearchError.termKeyNotSet`
     
    */
    func searchMusic(term: String, completion: @escaping MusicSearchHandler) {
        if term.trimmingCharacters(in: CharacterSet.whitespaces).count == 0 {
            // if term not set, directly return SearchError.termKeyNotSet error
            completion(nil, SearchError.termKeyNotSet)
            return
        }
        
        let options = ["term": term]
        
        do {
            let url = try SearchURL.generate(options: options)
            HTTPClient().searchMusic(url: url, completion: completion)
        } catch {
            completion(nil, error)
        }
    }
}
