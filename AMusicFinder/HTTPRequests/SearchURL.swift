//
//  SearchURL.swift
//  AMusicFinder
//
//  Created by Kaka on 26/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

/**
 SearchURL provides methods to generate URL-encoded searching URL.
 */
class SearchURL {
    /**
     Generate URL with search options.
     
     - parameters:
        - options: Should meet the key-value pairs defined in the
                    [Table](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/)
     
     - Version:
     0.1
     
     Only parameter "term" key in options is required and functional.
     
     */
    static func generate(options: [String: String]) throws -> URL {
        guard let term = options["term"] else {
            // no term key found
            throw SearchError.termKeyNotSet
        }
        
        if term.count == 0 {
            // term value is empty
            throw SearchError.termKeyNotSet
        }
        
        var components = URLComponents()
        components.scheme = "HTTPS"
        components.host = "itunes.apple.com"
        components.path = "/search"
        
        // need URL encoding 
        let queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "country", value: Locale.current.regionCode),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "entity", value: "song")
        ]
        
        components.queryItems = queryItems
        return components.url!
    }
}
