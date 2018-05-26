//
//  HTTPClient.swift
//  AMusicFinder
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

/**
 The music search result handler.
 
 - parameters:
    - result: The `MusicResults` returned
    - err: Error information
 
 */
typealias MusicSearchHandler = (_ result: MusicResults?, _ err: Error?) -> ()

/**
 HTTPClient provides methods for making HTTP requests.
 */
class HTTPClient {
    /// the session used for create `dataTask`
    private let session: URLSessionProtocol
    
    /**
     Can pass in a mock URLSession for testing.
     
     - parameters:
        - session: Default is `URLSession.shared`
     */
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    /**
     Search Apple Music with given URL.
     
     - parameters:
        - url: The url to reuqest. [iTunes Search API](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/)
        - completion: `MusicSearchHandler`
     
     - Version:
        0.1
     
     Only parameter "term" key in options is required and functional.
     
     - throws:
     `SearchError.termKeyNotSet` if "term" key not set.
     */
    func searchMusic(url: URL, completion: @escaping MusicSearchHandler) {
        let searchRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: RequestSettings.Timeout)
        
        let task = session.dataTask(with: searchRequest) { (data, response, err) in
            if err != nil {
                completion(nil, err)
                return
            }
            
            do {
                let musicResults = try JSONDecoder().decode(MusicResults.self, from: data!)
                completion(musicResults, nil)
            } catch {
                completion(nil, error)
            }
        }
        
        task.resume()
    }
}
