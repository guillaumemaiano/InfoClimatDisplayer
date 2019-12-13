//
//  WeatherStoreTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class WeatherStoreTests: XCTestCase {
    let folderPath = NSTemporaryDirectory() + "FileTests"
    
     override func setUp() {
           super.setUp()
           // destroy any datafile
           do {
               let fileManager = FileManager.default
               if fileManager.fileExists(atPath: folderPath)
               {
                   try fileManager.removeItem(atPath: folderPath)
               }

               try fileManager.createDirectory(atPath: folderPath, withIntermediateDirectories: false, attributes: nil)
           } catch let error {
               XCTFail("Test setup failed \(error)")
           }
           
       }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Several related failures with clear messages tested, no point having billions of microtests
    func testWeatherGrabber_WeatherStore_StoreData_createsFileWithContent() {
        // given
        let store = WeatherStore(pathString: folderPath)
        let expectation = XCTestExpectation(description: "Storing data creates a file")
        let dataString = UUID().uuidString
        // when
        store.storeData(dataString: dataString) {
            do {
                let fileManager = FileManager.default
                let filePath = "\(self.folderPath)/\(WeatherStore.nameString)"
                let isFileCreated = fileManager.fileExists(atPath: filePath)
                // not created, permission issue etc
                XCTAssert(isFileCreated, "File not found")
                let fileContents = try String(contentsOf: URL(fileURLWithPath: filePath))
                XCTAssertEqual(fileContents, dataString, "File does  not contain correct data: \(fileContents)")
            } catch let error {
                XCTFail("Test StoreData_createsFileWithContent failed: \(error)")
            }
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
        
    }
    
    func testWeatherGrabber_WeatherStore_ReadData_ReadsNoFile() {
        // given
        let store = WeatherStore(pathString: folderPath)
        let expectation = XCTestExpectation(description: "Reading data fails if no data")
        // when
        store.readData() {
            data in
            XCTAssertNil(data, "No data could be harvested")
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
    }
    
    func testWeatherGrabber_WeatherStore_ReadData_ReadsFile() {
        // given
        let store = WeatherStore(pathString: folderPath)
        let filePath = "\(folderPath)/\(WeatherStore.nameString)"
        let expectation = XCTestExpectation(description: "Reading data works")
        let dataString = UUID().uuidString
        
        // when
        store.storeData(dataString: dataString) {
            do {
                let fileManager = FileManager.default
                let isFileCreated = fileManager.fileExists(atPath: filePath)
                // not created, permission issue etc
                XCTAssert(isFileCreated, "File not found")
                let fileContents = try String(contentsOf: URL(fileURLWithPath: filePath))
                XCTAssertEqual(fileContents, dataString, "File does  not contain correct data: \(fileContents)")
            } catch let error {
                XCTFail("Test StoreData_createsFileWithContent failed: \(error)")
            }
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
        
    }
}
