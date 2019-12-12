//
//  PredictionError.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

enum PredictionError: Error, Equatable {
    // already running a request
    case inProgress
    // server is running the latest batch job, wait a bit
    case serverUpdating
    // too many requests
    case serverLimitExceeded
    // key refused, app can't update data
    case badRequest
    // unknown network error, pointless information for end user
    case invalidStatus
}
