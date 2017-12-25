//
//  StargazersUITests.swift
//  StargazersUITests
//
//  Created by Matteo Crespi on 25/12/2017.
//  Copyright © 2017 Matteo Crespi. All rights reserved.
//

import XCTest

class StargazersUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    func testBasicUsage() {
        let app = XCUIApplication()
        
        // Check that search functions correctly
        let searchUserSearchField = app.searchFields["Search user"]
        searchUserSearchField.tap()
        searchUserSearchField.typeText("facebook")
        
        // Check that accessing repositories works
        app.tables.staticTexts["facebook"].tap()
        
        // Check that pagination works correctly in the repositories screen
        for _ in 1...5 { app.tables.firstMatch.swipeUp() }
        XCTAssertGreaterThan(app.tables.cells.count, 50)
        
        // Check that accessing stargazers works
        app.tables.staticTexts["fbshipit"].tap()
        
        // Check that pagination works correctly in the stargazers screen
        for _ in 1...10 { app.tables.firstMatch.swipeUp() }
        XCTAssertGreaterThan(app.tables.cells.count, 100)
    }
    
}
