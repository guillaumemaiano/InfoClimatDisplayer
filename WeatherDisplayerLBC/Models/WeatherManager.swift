//
//  WeatherManager.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 13/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

struct WeatherManager {
    
    // MARK: - Private
    private let manager = PredictionManager.shared
    
    // MARK: - Properties
    static let shared = WeatherManager()
    
    // MARK: - Functions
    private init() {}
    
    func getWeatherInformation() -> [String:Prediction] {
        return [:]
    }
    // refreshData(store: WeatherStore, completionHandler: @escaping (String?, Error?) -> Void)
    // var needsRefresh: Bool
}
