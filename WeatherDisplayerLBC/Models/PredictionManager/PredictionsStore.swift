//
//  PredictionsStore.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

struct PredictionStore: Decodable, Encodable {
    var requestDate: Date
    var prediction: String
}
