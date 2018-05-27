//
//  AMusicFinderUITests.swift
//  AMusicFinderUITests
//
//  Created by Kaka on 25/5/2018.
//  Copyright © 2018 Kaka. All rights reserved.
//

import XCTest

class AMusicFinderUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        
        app = XCUIApplication()
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearchRequest() {
        let tableView = app.tables.element
        XCTAssertTrue(tableView.exists, "tableview should exist")
        
        // activate searchBar
        let searchBar = app.searchFields.element
        XCTAssertTrue(searchBar.exists, "searchBar should exist")
        
        searchBar.tap()
        // input "swift" and search
        searchBar.typeText("swift")
        app.keyboards.buttons["Search"].tap()
        
        // wait for table view to reload
        let cellReloaded = tableView.cells.element(boundBy: 5).waitForExistence(timeout: 10)
        XCTAssertTrue(cellReloaded, "cell with index 10 should exist")
        XCTAssertEqual(50, tableView.cells.count, "should have 50 music results")
        
        // tap to preview
        tableView.cells.element(boundBy: 5).tap()
        
        let avPlayerShown = app.buttons["Done"].waitForExistence(timeout: 5)
        XCTAssertTrue(avPlayerShown, "avplayer should show")
        
        // dismiss avplayer
        app.buttons["Done"].tap()
        
        // test empty seach case
        searchBar.tap()
        // delete "swift"
        deleteField(searchBar: searchBar)

        // also is an empty term
        searchBar.typeText("  ")
        app.keyboards.buttons["Search"].tap()
        
        let alertShown = app.alerts.element.waitForExistence(timeout: 5)
        XCTAssertTrue(alertShown, "Alert should show when search empty term")
        
        // dismiss
        app.alerts.buttons["OK"].tap()
        
        // after error, searchbar should return active
        let searchButtonShown = app.keyboards.buttons["Search"].waitForExistence(timeout: 5)
        XCTAssertTrue(searchButtonShown, "searchbar should return first response")
    }
    
    private func deleteField(searchBar: XCUIElement) {
        if let fieldValue = searchBar.value as? String {
            var deleteString: String = ""
            for _ in 0 ..< fieldValue.count {
                deleteString += "\u{8}"
            }
            searchBar.typeText(deleteString)
        }
    }
}
