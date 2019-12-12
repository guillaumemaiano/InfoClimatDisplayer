//
//  PredictionCoders.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

// two basic utility classes purely for code readability
class PredictionsStoreDecoder: JSONDecoder {
    override init() {
            super.init()
            keyDecodingStrategy = .convertFromSnakeCase
            dateDecodingStrategy = .iso8601
        }
}

class PredictionsStoreEncoder: JSONEncoder {
    
        override init() {
            super.init()
            keyEncodingStrategy = .convertToSnakeCase
            dateEncodingStrategy = .iso8601
    }
}
