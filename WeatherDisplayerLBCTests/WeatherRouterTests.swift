//
//  WeatherRouterTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class WeatherRouterTests: XCTestCase {
    
    // request is centered on Notre-Dame, eg Kilometre Zero.
    let testURLString = "https://www.infoclimat.fr/public-api/gfs/json?_ll=48.85341,2.3488&_auth=ABpQRwF%2FVnQEKVJlUyVQeQRsATQIfgYhUy9QM1s%2BVShSOV8%2BUTEAZlI8VShVeldhUH0ObVtgVGQKYVUtAXMEZQBqUDwBalYxBGtSN1N8UHsEKgFgCCgGIVM4UD5bKFU3UjRfM1EsAGBSPFUzVXtXYVBiDmhbe1RzCmhVNwFrBGIAalA0AWVWPARiUjBTfFB7BDIBNQhiBmtTN1A1WzVVNFJgXzpRZgBnUjlVMFV7V2RQaw5nW2BUZQpsVTcBZQR4AHxQTQERVikEK1JyUzZQIgQqATQIaQZq&_c=dc7fd2774b0b3b7fd3a70bedbdd827ce"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // check the network calls fetches the assigned url
    func testWeatherGrabber_WeatherRouter_FetchWeather_CallsCorrectURL() {
        // given
        let url = URL(string: testURLString)!
        let predictionRouter = WeatherRouter(url: url)
        let session = URLSessionMock()
        let expectation = XCTestExpectation(description: "Prediction url is fetched properly")
        
        // when
        predictionRouter.fetch(using: session) {
            XCTAssertEqual(URL(string: self.testURLString), session.lastUrl)
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
    }
    
    // check the network request was started
    func testWeatherGrabber_WeatherRouter_FetchWeather_CallsResume() {
        // given
        let url = URL(string: testURLString)!
        let predictionRouter = WeatherRouter(url: url)
        let session = ResumableTaskURLSessionMock()
        let expectation = XCTestExpectation(description: "Downloading weather triggers resume")
        // when
        predictionRouter.fetch(using: session) {
            XCTAssert(session.dataTask?.resumeWasCalled ?? false)
            expectation.fulfill()
        }
        // then
        wait(for: [expectation], timeout: 5)
    }
    
    // check data was properly retrieved
    func testWeatherGrabber_WeatherRouter_FetchWeather_RetrievesCorrectData() {
        // given
        let url = URL(string: testURLString)!
        let predictionRouter = WeatherRouter(url: url)
        let session = CustomizableURLSessionMock()
        let stringData = UUID().uuidString
        session.testData = Data(stringData.utf8)
        let expectation = XCTestExpectation(description: "Downloading weather downloads correct test data")
        // when
        predictionRouter.fetch(using: session) {
            XCTAssertEqual(predictionRouter.weatherData, stringData)
            
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 5)
    }
    
    // check error was properly recorded
    func testWeatherGrabber_WeatherRouter_FetchWeather_RegistersError() {
        // given
        let url = URL(string: testURLString)!
        let predictionRouter = WeatherRouter(url: url)
        let session = CustomizableURLSessionMock()
        let error = TestError.dummyFailure
        session.testError = error
        let expectation = XCTestExpectation(description: "Downloading weather downloads correct test data")
        // when
        predictionRouter.fetch(using: session) {
            // First check the error isn't nil
            XCTAssertNotNil(predictionRouter.error)
            // then we’ll verify that the error is of the right
            // type, to make debugging easier in case of failures.
            XCTAssertTrue(
                predictionRouter.error is TestError,
                "Unexpected error type: \(type(of: predictionRouter.error))"
            )
            // Verify that our error is equal to what we set in the session mock
            XCTAssertEqual(predictionRouter.error as? TestError, error)
            expectation.fulfill()
        }
        
        // then
        wait(for: [expectation], timeout: 5)
    }
}

// MARK: SUPPORT CODE: MOCKS & PLUGS
// MARK: testWeatherGrabber_WeatherRouter_FetchWeather_CallsCorrectURL -
// dummy datatask
class DataTaskMock: URLSessionDataTask {
    
    override func resume() {
    }
    
    override init() {
        // superclass init deprecated in iOS 13
    }
}

// mock
class URLSessionMock: URLSessionProtocol {
    var lastUrl: URL?
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        defer {
            completionHandler(nil, nil, nil)
        }
        lastUrl = url
        return DataTaskMock()
    }
}

// MARK: testWeatherGrabber_WeatherRouter_FetchWeather_CallsResume -
// mock required for resumable task testing
class ResumableTaskURLSessionMock: URLSessionProtocol {
    
    var dataTask: ResumableDataTaskMock?
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let newDataTask = ResumableDataTaskMock(completionHandler: completionHandler)
        dataTask = newDataTask
        return newDataTask
    }
}
// mock
class ResumableDataTaskMock: URLSessionDataTask {
    
    // we need the handler to call it later
    var completionHandler:(Data?,
    URLResponse?,
    Error?) -> Void
    // track whether the resume is properly called
    var resumeWasCalled = false
    
    override func resume() {
        // flip the boolean and call the completion
        resumeWasCalled = true
        completionHandler(nil, nil, nil)
    }
    
    init(completionHandler: @escaping (Data?,
        URLResponse?,
        Error?) -> Void) {
        self.completionHandler = completionHandler
    }
}

// MARK: testWeatherGrabber_WeatherRouter_FetchWeather_RetrievesCorrectData -
// mock with customizable data/error
class CustomizableURLSessionMock: URLSessionProtocol {
    var testData: Data? = nil
    var testError: Error? = nil
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        defer {
            completionHandler(testData, nil, testError)
        }
        
        return CustomizableDataTaskMock()
    }
}

class CustomizableDataTaskMock: URLSessionDataTask {
    override func resume() { }
    override init() { }
}

// MARK: testWeatherGrabber_WeatherRouter_FetchWeather_CallsCorrectURL -
// dummy error
enum TestError: Error {
    case dummyFailure
}
