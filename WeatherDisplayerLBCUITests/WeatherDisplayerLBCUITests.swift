//
//  WeatherDisplayerLBCUITests.swift
//  WeatherDisplayerLBCUITests
//
//  Created by guillaume MAIANO on 04/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest

class WeatherDisplayerLBCUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

        func testUIon20191219() {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
        let tablesQuery = app.tables
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["2019-12-20 07:00:00"]/*[[".cells.staticTexts[\"2019-12-20 07:00:00\"]",".staticTexts[\"2019-12-20 07:00:00\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["2019-12-19 04:00:00"]/*[[".cells.staticTexts[\"2019-12-19 04:00:00\"]",".staticTexts[\"2019-12-19 04:00:00\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["WeatherDisplayerLBC.DetailsView"].buttons["Retour à la carte"].tap()
            XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["www.infoclimat.fr"]/*[[".cells.staticTexts[\"www.infoclimat.fr\"]",".staticTexts[\"www.infoclimat.fr\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.navigationBars["WeatherDisplayerLBC.AttributionWebView"].buttons["Retour à la carte"].tap()
        tablesQuery/*@START_MENU_TOKEN@*/.staticTexts["2019-12-25 16:00:00"]/*[[".cells.staticTexts[\"2019-12-25 16:00:00\"]",".staticTexts[\"2019-12-25 16:00:00\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.swipeDown()
                                                
            
            
    }

    func testLaunchPerformance() {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
