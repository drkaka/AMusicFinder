//
//  ResultsViewProtocol.swift
//  AMusicFinder
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import Foundation

// delegate to ViewController
@objc
protocol ResultViewDelegate {
    /// music is reloaded
    func musicReloaded()
    /// music priview is downloaded
    func previewDownloaded(row: Int, imageData: Data)
}

// required in ViewModel
protocol ResultsViewProtocol {
    /// The count of music
    var musicCount: Int {get}
    /// return trackName, artistName, previewUrl
    func musicDetail(row: Int) -> (String, String, String)
    /// Request a music proview
    func requestMusicPreview(row: Int)
    /// search music with the given search term
    func searchMusic(term: String, completion: @escaping (Error?) ->())
}
