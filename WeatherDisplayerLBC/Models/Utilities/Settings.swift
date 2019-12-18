//
//  Settings.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

class SettingsManager {
    
    class func getStaleDuration() -> Int {
        return UserDefaults.standard.integer(forKey: Constants.SettingsKeys.validityKey)
    }
}
