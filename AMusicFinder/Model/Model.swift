//
//  Model.swift
//  AMusicFinder
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

/**
 The music information.
 
 - Version:
 0.1
 
 Only `trackName`, `artistName`, `artworkUrl60` and `previewUrl` are parsed.
 */
struct MusicInfo: Codable, Equatable {
    var trackName: String
    var artistName: String
    var artworkUrl60: String
    var previewUrl: String
    
    enum CodingKeys: String, CodingKey {
        case trackName
        case artistName
        case artworkUrl60
        case previewUrl
    }
    
    init(trackName: String, artistName: String, artworkUrl60: String, previewUrl: String) {
        self.trackName = trackName
        self.artistName = artistName
        self.artworkUrl60 = artworkUrl60
        self.previewUrl = previewUrl
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.trackName = try container.decode(String.self, forKey: .trackName)
        self.artistName = try container.decode(String.self, forKey: .artistName)
        self.artworkUrl60 = try container.decode(String.self, forKey: .artworkUrl60)
        self.previewUrl = try container.decode(String.self, forKey: .previewUrl)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(trackName, forKey: .trackName)
        try container.encode(artistName, forKey: .artistName)
        try container.encode(artworkUrl60, forKey: .artworkUrl60)
        try container.encode(previewUrl, forKey: .previewUrl)
    }
}

/**
 The result for a music search request.
 */
struct MusicResults: Codable, Equatable {
    var resultCount: Int
    var results: [MusicInfo]
    
    enum CodingKeys: String, CodingKey {
        case resultCount
        case results
    }
    
    init(count: Int, musics: [MusicInfo]) {
        resultCount = count
        results = musics
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.resultCount = try container.decode(Int.self, forKey: .resultCount)
        self.results = try container.decode([MusicInfo].self, forKey: .results)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(resultCount, forKey: .resultCount)
        try container.encode(results, forKey: .results)
    }
}
