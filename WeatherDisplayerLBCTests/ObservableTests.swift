//
//  ObservableTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 18/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class ObservableTests: XCTestCase {
    
    private class BoundMock {
        
        enum BoundMockEvent {
            case modified
        }

        private var targets: [BoundMockEvent: ()->()] = [:]

        var boundValue: Int?
        {
            // all I want is to notify the binder something happened
            didSet {
                targets[.modified]?()
            }
        }

        var changedClosure: (()->())?
        
        func valueChanged() {
            changedClosure?()
        }
        
        func replaceTarget(action: @escaping (()-> ()), for controlEvents: BoundMockEvent) {
        
            // simulate a system allowing code that checks events and grab appropriate actions
            // it's just a dictionary with no complex code ^^
            targets[.modified] = action
        }

        func bind(to observable: Observable<Int>) {
            replaceTarget(action: self.valueChanged, for: .modified)
            
            changedClosure = { [weak self] in
                observable.bindingChanged(to: self?.boundValue ?? 0)
            }
            
            observable.valueChanged = { [weak self] newValue in
                if let value = newValue {
                    self?.boundValue = value
                }
            }
        }
    }
    
    func testViewUtilities_Observable_ValueChanged_CorrectData() {
        // given
        // create reference value for changed value
        let reference = 42
        // create SUT
        let temperature: Observable<Int> = Observable(5)
        // bind SUT
        let mock = BoundMock()
        mock.bind(to: temperature)
        // when
        // modify observable value
        temperature.value = reference
        
        // then
        XCTAssertEqual(mock.boundValue, reference, "Reference value should be equal to current observed value")
        
    }
    func testViewUtilities_Observable_BoundValueChanged_CorrectData() {
        // given
        // create reference value for changed value
        let reference = 42
        // create SUT
        let temperature: Observable<Int> = Observable(5)
        // bind SUT
        let mock = BoundMock()
        mock.bind(to: temperature)
        // when
        // modify bound value
        mock.boundValue = reference
        // then
        XCTAssertEqual(temperature.value, reference, "Reference value should be equal to current observed value")
        
    }
    
}
