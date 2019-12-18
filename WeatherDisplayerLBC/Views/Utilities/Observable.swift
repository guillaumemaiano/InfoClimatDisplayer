//
//  Observable.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 18/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

// Usually I'd use Bond, Combine or RxSwift
// but since the rules say "as little external libraries as possible & no SwiftUI"

class Observable<Observed_Type> {
    private var observedValue: Observed_Type?
    
    var value: Observed_Type? {
        get {
            return observedValue
        }
        set {
            observedValue = newValue
            valueChanged?(observedValue)
        }
    }
    
    init(_ value: Observed_Type) {
        observedValue = value
    }
    
    var valueChanged: ((Observed_Type?) -> ())?
    
    func bindingChanged(to newValue: Observed_Type) {
        observedValue = newValue
    }
}
