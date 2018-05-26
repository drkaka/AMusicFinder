//
//  HTTPClientTests.swift
//  AMusicFinderTests
//
//  Created by Kaka on 26/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import XCTest
@testable import AMusicFinder

/**
 Mock Timeout URLSession
 */
class URLSessionTimeoutMock: URLSessionProtocol {
    var completion: DataTaskResult?
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTaskProtocol {
        self.completion = completion
        return URLSessionDataTaskTimeoutMock(session: self, request: request)
    }
}

/**
 Mock Timeout URLSessionDataTask
 */
class URLSessionDataTaskTimeoutMock: URLSessionDataTaskProtocol {
    private let session: URLSessionTimeoutMock
    private let request: URLRequest
    init(session: URLSessionTimeoutMock, request: URLRequest) {
        self.session = session
        self.request = request
    }
    func resume() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + request.timeoutInterval) {
            self.session.completion!(nil, nil, NSError(domain: "timeout", code: NSURLErrorTimedOut, userInfo: nil))
        }
    }
}

/**
 Mock URLSession with given musics.
 */
class URLSessionDataMock: URLSessionProtocol {
    let musics: [MusicInfo]
    var completion: DataTaskResult?
    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> ()) -> URLSessionDataTaskProtocol {
        self.completion = completion
        return URLSessionDataTaskDataMock(session: self, request: request)
    }
    
    init(musics: [MusicInfo]) {
        self.musics = musics
    }
}

/**
 Mock URLSessionDataTask for returned data check.
 */
class URLSessionDataTaskDataMock: URLSessionDataTaskProtocol {
    private let session: URLSessionDataMock
    private let request: URLRequest
    init(session: URLSessionDataMock, request: URLRequest) {
        self.session = session
        self.request = request
    }
    func resume() {
        DispatchQueue.global(qos: .background).async {
            let searchResult = MusicResults(count: self.session.musics.count, musics: self.session.musics)
            let data = try! JSONEncoder().encode(searchResult)
            self.session.completion!(data, nil, nil)
        }
    }
}

class HTTPClientTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    /// test search return with timeout error
    func testSearchMusicTimeout() {
        let exp = expectation(description: "Waiting for requesting to be done")
        let searchURL = URL(string: "https://itunes.apple.com/search?term=swift&country=US&media=music&entity=song")
        
        HTTPClient(session: URLSessionTimeoutMock()).searchMusic(url: searchURL!, completion: { searchResult, err in
            // timeout should be observed
            if let error = err {
                XCTAssertEqual(NSURLErrorTimedOut, (error as NSError).code)
            } else {
                XCTFail("should have error returned")
            }
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: RequestSettings.Timeout + 1)
    }
    
    /// test search return with mock data
    func testSearchMusicWithData() {
        // create the mock result
        let normalMusics = [
            MusicInfo(trackName: "trackName1", artistName: "artistName1", artworkUrl60: "artworkUrl601", previewUrl: "previewUrl1"),
            MusicInfo(trackName: "trackName2", artistName: "artistName2", artworkUrl60: "artworkUrl602", previewUrl: "previewUrl2"),
            MusicInfo(trackName: "trackName3", artistName: "artistName3", artworkUrl60: "artworkUrl603", previewUrl: "previewUrl3")
        ]
        
        let emptyMusics: [MusicInfo] = [MusicInfo]()
        
        testWithMockData(cases: [normalMusics, emptyMusics])
    }
    
    /// test with given cases
    private func testWithMockData(cases: [[MusicInfo]]) {
        cases.forEach { musics in
            let exp = expectation(description: "Waiting for requesting to be done")
            let searchURL = URL(string: "https://itunes.apple.com/search?term=swift&country=US&media=music&entity=song")
            
            HTTPClient(session: URLSessionDataMock(musics: musics)).searchMusic(url: searchURL!, completion: { searchResult, err in
                guard let result = searchResult else {
                    XCTFail("should have search results")
                    return
                }
                
                XCTAssertNil(err, "Error should be nil")
                
                XCTAssertEqual(musics.count, result.resultCount, "Result count wrong")
                XCTAssertEqual(musics, result.results, "Result not match")
                
                exp.fulfill()
            })
            
            wait(for: [exp], timeout: RequestSettings.Timeout)
        }
    }
    
    /// test a real request to iTunes API
    func testSearchResult() {
        let exp = expectation(description: "Waiting for requesting to be done")
        let searchURL = URL(string: "https://itunes.apple.com/search?term=swift&country=US&media=music&entity=song")
        
        HTTPClient().searchMusic(url: searchURL!, completion: { searchResult, err in
            guard let results = searchResult else {
                XCTFail("should have search results")
                return
            }
            
            XCTAssertNil(err, "Error should be nil")
            XCTAssertEqual(50, results.resultCount, "Default should return 50 results")
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: RequestSettings.Timeout)
    }
}
