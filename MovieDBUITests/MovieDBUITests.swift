//
//  MovieDBDemoUITests.swift
//  MovieDBDemoUITests
//
//  Created by Jason Terhorst on 6/2/19.
//  Copyright © 2019 Jason Terhorst. All rights reserved.
//

import XCTest

class MovieDBUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSearch() {
        
        let app = XCUIApplication()
        let searchMoviesSearchField = app.navigationBars["Movies"].searchFields["Search movies"]
        searchMoviesSearchField.tap()
        searchMoviesSearchField.typeText("Testing")
        app.tables.cells.containing(.staticText, identifier:"This is a test movie").staticTexts["Testing"].tap()
        app.navigationBars["About"].buttons["Back"].tap()
        
    }

    func testSectionSelector() {
        
        let toolbar = XCUIApplication().toolbars["Toolbar"]
        toolbar/*@START_MENU_TOKEN@*/.buttons["Popular"]/*[[".segmentedControls.buttons[\"Popular\"]",".buttons[\"Popular\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        toolbar/*@START_MENU_TOKEN@*/.buttons["Top Rated"]/*[[".segmentedControls.buttons[\"Top Rated\"]",".buttons[\"Top Rated\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        toolbar/*@START_MENU_TOKEN@*/.buttons["Now Playing"]/*[[".segmentedControls.buttons[\"Now Playing\"]",".buttons[\"Now Playing\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
    }
    
}
