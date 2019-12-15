//
//  WeatherManagerTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 13/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class WeatherManagerTests: XCTestCase {
    
    func testWeatherUtilities_WeatherManager_Creation() {
        let weatherManager = WeatherManager.shared
        let information = weatherManager.getWeatherInformation()
    }
}
