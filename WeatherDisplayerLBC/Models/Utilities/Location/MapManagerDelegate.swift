//
//  MapManagerDelegate.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 15/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation
import CoreLocation

class MapManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    var locationStatus = "Status not determined"
    var locationFixFound = false
    var locationUpdatedClosure: (String) ->()
    
    init(didUpdateLocation: @escaping (String) -> () = { _ in}) {
        locationUpdatedClosure = didUpdateLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // We've (at least once) gone under a certain minimum accuracy required to consider we have a "fix"
        // we could use that to reflect that information on the UI (color, shape...)
        // however, it's brittle because we could well have lost the fix
        // ** Theorical scenario: I'm in California going through the canyons.
        // ** When I was in the plains, I had GPS and cell tower location, my fix was easy.
        // ** Now, with the trees and rocks all around, I have a hard time getting enough satellite cover
        // ** And cell towers are a distant dream... I have lower accuracy.
        // ** By personal experience, I could easily be in the other valley.
        // ** In this case, the app doesn't need high precision, because our weather data doesn't take the geography into account.
        if !locationFixFound {
            for location in locations {
                if location.horizontalAccuracy < 25.0 {
                    locationFixFound = true
                }
            }
            if let latest = locations.last {
                let fmt = NumberFormatter()
                fmt.numberStyle = .decimal
                // needed because the location class expects this format for location string
                fmt.decimalSeparator = "."
                fmt.usesGroupingSeparator = false
                fmt.maximumFractionDigits = 5
                fmt.maximumSignificantDigits = 7
                let locationString = "\(fmt.string(from: NSNumber(value: latest.coordinate.latitude)) ?? ""),\(fmt.string(from: NSNumber(value: latest.coordinate.longitude)) ?? "")"
                locationUpdatedClosure(locationString)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        manager.stopUpdatingLocation()
        print("Location manager stopped due to error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization Status changed")
        var shouldRequestLocationUpdates = false
        
        switch status {
        case CLAuthorizationStatus.restricted:
            locationStatus = "Restricted Access to location"
        case CLAuthorizationStatus.denied:
            locationStatus = "User denied access to location"
        case CLAuthorizationStatus.notDetermined:
            locationStatus = "Status not determined"
        default:
            locationStatus = "Allowed to location Access"
            shouldRequestLocationUpdates = true
        }
        
        if (shouldRequestLocationUpdates == true) {
            NSLog("Location to Allowed")
            // Start location services
            manager.startUpdatingLocation()
        } else {
            NSLog("Denied access: \(locationStatus)")
        }
    }
}
