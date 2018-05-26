//
//  SearchURLTests.swift
//  AMusicFinderTests
//
//  Created by Kaka on 26/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import XCTest
@testable import AMusicFinder

class SearchURLTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    /// test option without term key set
    func testSearchMusicWithoutTermKey() {
        XCTAssertThrowsError(try SearchURL.generate(options: ["a": "b"])) { error in
            XCTAssertEqual(error as! SearchError, SearchError.termKeyNotSet)
        }
    }
    
    /// test option with empty term value
    func testSearchURLGeneratingWithEmptyTermKey() {
        XCTAssertThrowsError(try SearchURL.generate(options: ["term": ""])) { error in
            XCTAssertEqual(error as! SearchError, SearchError.termKeyNotSet)
        }
    }
    
    /// test generated URL with URL-encoded characters
    func testSearchURLGeneratingWithURLEncodableCharacter() {
        guard let countryCode = Locale.current.regionCode else {
            XCTFail("Can not get country Code")
            return
        }
        
        XCTAssertEqual(2, countryCode.count, "Country code length wrong")
        
        let searchTerm = "swift sheeran"
        let urlString = "HTTPS://itunes.apple.com/search?term=swift%20sheeran&country=\(countryCode)&media=music&entity=song"
        
        do {
            let searchURL = try SearchURL.generate(options: ["term": searchTerm])
            XCTAssertEqual(urlString, searchURL.absoluteString, "Generated URL wrong.")
        } catch {
            XCTFail("should not throw with fulfilled search options. \(error.localizedDescription)")
        }
    }
}
