//
//  ResultsViewVMTests.swift
//  AMusicFinderTests
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import XCTest
@testable import AMusicFinder

class ResultsViewVMTests: XCTestCase {
    private let viewModel = ResultsViewViewModel()
    
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchMusicWithEmptyTerm() {
        let exp = expectation(description: "Waiting for closure to return")
        
        viewModel.searchMusic(term: "") { err in
            // should return an error
            XCTAssertNotNil(err)
            
            if let error = err as? SearchError {
                XCTAssertEqual(SearchError.termKeyNotSet, error, "Error should be SearchError.termKeyNotSet")
            } else {
                XCTFail("err should be SearchError type")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: RequestSettings.Timeout)
    }
    
    func testSearchResult() {
        let exp = expectation(description: "Waiting for closure to return")
        
        viewModel.searchMusic(term: "swift", completion: { err in
            
            XCTAssertNil(err, "Error should be nil")
            // should get reloaded musics
            XCTAssertEqual(50, self.viewModel.musicCount, "Default should return 50 results")
            
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: RequestSettings.Timeout)
    }
}
