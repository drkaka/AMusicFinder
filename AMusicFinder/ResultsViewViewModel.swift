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
    
    /// music information to show
    private var musics = [MusicInfo]()
    
    /// The count of music
    var musicCount: Int {
        return musics.count
    }
    
    /// return trackName, artistName, previewUrl
    func musicDetail(row: Int) -> (String, String, String) {
        let music = musics[row]
        return (music.trackName, music.artistName, music.previewUrl)
    }
    
    /// Request a music proview
    func requestMusicPreview(row: Int) {
        guard let url = URL(string: musics[row].artworkUrl60) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { responseData, responseUrl, err in
            if err != nil {
                // handle error that is not recognized. e.g., log and retry
                return
            }
            
            // image data
            if let data = responseData {
                if let dele = self.delegate {
                    dele.previewDownloaded(row: row, imageData: data)
                }
            }
        }
        
        // Run task
        task.resume()
    }
    
    /**
     Search music with given search term.
     
     - parameters:
        - term: The count of `String` should > 0.
        - completion: return whether there is an error or not
     
    */
    func searchMusic(term: String, completion: @escaping (Error?) ->()) {
        if term.trimmingCharacters(in: CharacterSet.whitespaces).count == 0 {
            // if term not set, directly return SearchError.termKeyNotSet error
            completion(SearchError.termKeyNotSet)
            return
        }
        
        let options = ["term": term]
        
        do {
            let url = try SearchURL.generate(options: options)
            HTTPClient().searchMusic(url: url) { searchResult, err in
                if let error = err {
                    // Got an Error
                    completion(error)
                    return
                }
                
                if let result = searchResult {
                    // Got new results. Notice to reload table.
                    self.musics = result.results
                    if let dele = self.delegate {
                        dele.musicReloaded()
                    }
                }
                completion(nil)
            }
        } catch {
            completion(error)
        }
    }
}
