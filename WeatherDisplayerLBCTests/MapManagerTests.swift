//
//  MapManagerTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 15/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class MapManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_LocationUtilities_MapManager_Creation() {
        // given
        let sut = MapManager()
        // then
        XCTAssertNotNil(sut.locationManager, "Map manager has no location manager")
    }
    
    func test_LocationUtilities_MapManager_DelegateValid() {
        // given
        let sut = MapManager()
        // then
        XCTAssertNotNil(sut.locationManager.delegate, "Location manager has no location delegate")
    }

}
