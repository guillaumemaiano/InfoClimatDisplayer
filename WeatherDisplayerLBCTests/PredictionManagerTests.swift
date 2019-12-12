//
//  PredictionManagerTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class PredictionManagerTests: XCTestCase {
    
    override func setUp() {
        let fs = FileManager.default
        do {
            if let dirPath = fs.urls(for: .documentDirectory, in: .userDomainMask).first {
                let path = dirPath.appendingPathComponent(WeatherStore.nameString).path
                if fs.fileExists(atPath: path) {
                    try fs.removeItem(atPath: path)
                }
            }
        } catch {
            XCTFail("Couldn't remove file")
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWeatherGrabber_PredictionManager_StartsNicely() {
        // given
        let manager = PredictionManager.shared
        // when
        // then
        XCTAssert(manager.needsRefresh)
    }
    
    func testWeatherGrabber_PredictionManager_RequestUpdate_RunsSingly() {
        // given
        let manager = PredictionManager.shared
        let expectation = XCTestExpectation(description: "Update requests run singly")
        // when
        manager.requestUpdate() { firstRequestData, firstRequestError in
            manager.requestUpdate() {
                secondRequestData, secondRequestError in
                // then
                XCTAssertNotNil(secondRequestError, "update should be in progress")
                expectation.fulfill()
            }
        }
        
        // then
        wait(for: [expectation], timeout: 5)
        
    }
}
