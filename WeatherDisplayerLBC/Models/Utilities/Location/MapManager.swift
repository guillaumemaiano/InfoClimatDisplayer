//
//  MapManager.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 15/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation
//
import CoreLocation

struct MapManager: MapManagerProtocol {
    let locationManager: CLLocationManager
    // hold the delegate, since CLLocationManager's delegate is weak
    let locationDelegate: CLLocationManagerDelegate
        
    init(delegate: CLLocationManagerDelegate = MapManagerDelegate()) {
        locationDelegate = delegate
        locationManager = CLLocationManager()
        locationManager.delegate = locationDelegate
        // Since we're accessing weather data, which is based on kilometer-wide predictions, we do not need meter precision
        // kCLLocationAccuracyBest is therefore extreme overkill, and it eats the battery up
        // We don't even need kCLLocationAccuracyHundredMeters, since the datasource used by our system doesn't take local geography into account (some weather data systems do)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        // Needed for location access
        locationManager.requestWhenInUseAuthorization()
        // Needed for location digital fencing
        locationManager.requestAlwaysAuthorization()
        // don't bother the user with the indicator if in background since we're low-energy
        locationManager.showsBackgroundLocationIndicator = false
    }
}

protocol MapManagerProtocol {
     init(delegate: CLLocationManagerDelegate)
}
