//
//  PredictionManagerTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class PredictionManagerBaseTests: XCTestCase {
    
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
}

class APredictionManagerSetupTests: PredictionManagerBaseTests {
    // There is a trick in the name
    // XCTests run (by default) in alphanumerical order, and since this tests the start of the singleton
    // it needs to run first hence the addition of "Always"
    func testWeatherGrabber_PredictionManager_AlwaysStartsNicely() {
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

class PredictionManagerTests: PredictionManagerBaseTests {
    
    func testWeatherGrabber_PredictionManager_RequestUpdate_DoesNotError() {
        // given
        let manager = PredictionManager.shared
        let expectation = XCTestExpectation(description: "Update runs")
        // when
        
        manager.requestUpdate() {
            data, error in
            // then
            XCTAssertNil(error, "update should not respond with an error")
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
    }
    
    func testWeatherGrabber_PredictionManager_RequestUpdate_RunsOffline() {
        // given
        let store = WeatherStore()
        let dataString = UUID().uuidString
        let encoder = PredictionsStoreEncoder()
        var expectationString: String = ""
        let expectation = XCTestExpectation(description: "When valid data is available on disk, it gets picked up rather than a new request made")
        // simulate a previous successful request dating 5 seconds ago
        let predictions = PredictionStore(requestDate: Date().addingTimeInterval(-5), prediction: "\(dataString)")
        do {
            let contents = try encoder.encode(predictions)
            expectationString = String(data: contents, encoding: .utf8) ?? ""
            store.storeData(dataString: expectationString) {}
            
        } catch {
            XCTFail("encoding failed")
        }
        let manager = PredictionManager.shared
        // when
        manager.requestUpdate() {
            data, error in
            print("error: \(String(describing: error))data: \(String(describing: data))")
            // then
            XCTAssertEqual(dataString, data, "data from file should correspond to data stored prior")
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
    }
}

// multiple small test classes can run in parallel
class PredictionManagerOutdatedTests: PredictionManagerBaseTests {
    
    func testWeatherGrabber_PredictionManager_RequestUpdate_Outdated() {
        // given
        let store = WeatherStore()
        let dataString = UUID().uuidString
        let encoder = PredictionsStoreEncoder()
        var expectationString: String = "Mock very old data. Rain for 40 days. Sea level rising."
        let expectation = XCTestExpectation(description: "When request is outdated, new data gets picked up")
        // simulate a previous successful request dating 600 seconds ago
        let predictions = PredictionStore(requestDate: Date().addingTimeInterval(-600), prediction: expectationString)
        do {
            let contents = try encoder.encode(predictions)
            expectationString = String(data: contents, encoding: .utf8) ?? ""
            store.storeData(dataString: expectationString) {
                let manager = PredictionManager.shared
                // XCTest Suites runs mean the manager may have existing state
                manager.forceReset()
                // when
                XCTAssert(manager.needsRefresh, "New manager pulling outdated disk data should need a refresh")
                manager.requestUpdate() {
                    data, error in
                    XCTAssertFalse(manager.needsRefresh, "Manager just obtained a refresh")
                    // then
                    XCTAssertNotEqual(dataString, data, "data from file should not correspond to data stored prior")
                    expectation.fulfill()
                }
                
            }
        } catch {
            XCTFail("encoding failed")
        }
        // then
        wait(for: [expectation], timeout: 5)
    }
    
}
