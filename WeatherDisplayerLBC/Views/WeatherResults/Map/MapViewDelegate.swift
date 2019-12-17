//
//  MapViewDelegate.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation
import MapKit
import SwiftyDrop

class WeatherMapViewDelegate: NSObject, MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        // move rather than jump like a crazy dot
        mapView.setCenter(userLocation.coordinate, animated: true)
    }
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        // Not critical, application will load the weather for Paris
        // Warn the user nonetheless
        Drop.down("Cannot locate user", state: .warning)
    }
}
