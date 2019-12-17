//
//  Constants.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

struct Constants {
    
    struct UI {
        struct WeatherPredictionsTableViewNames {
            // information cell reuse identifier
            static let infoCellName = "infoCell"
            // terms & conditions cell reuse identifier
            static let tAndCCellName = "attributionCell"
            // prediction cell reuse identifier
            static let weatherPredictionCellName = "weatherCell"
        }
        
        struct Map {
            // we do not require high precision, but we'd like to show where we are in Europe
            static let latitudinalMeters = 2000.0
            static let longitudinalMeters = 2000.0
        }
    }
    
    struct Endpoint {

        private static let publicAuthKey = "ABpQRwF%2FVnQEKVJlUyVQeQRsATQIfgYhUy9QM1s%2BVShSOV8%2BUTEAZlI8VShVeldhUH0ObVtgVGQKYVUtAXMEZQBqUDwBalYxBGtSN1N8UHsEKgFgCCgGIVM4UD5bKFU3UjRfM1EsAGBSPFUzVXtXYVBiDmhbe1RzCmhVNwFrBGIAalA0AWVWPARiUjBTfFB7BDIBNQhiBmtTN1A1WzVVNFJgXzpRZgBnUjlVMFV7V2RQaw5nW2BUZQpsVTcBZQR4AHxQTQERVikEK1JyUzZQIgQqATQIaQZq"
        private static let check = "dc7fd2774b0b3b7fd3a70bedbdd827ce"
        
        static func weatherServer(ll: String? = nil) -> URL {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "www.infoclimat.fr"
            components.path = "/public-api/gfs/json"
            components.percentEncodedQueryItems = [
                    URLQueryItem(name: "_ll", value: ll?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "48.85341,2.3488"),
                    URLQueryItem(name: "_auth", value: publicAuthKey),
                    URLQueryItem(name:"_c", value: check)
            ]
            return components.url ??
                    Foundation.URL(string: "https://www.infoclimat.fr/public-api/gfs/json?_ll=48.85341,2.3488&_auth=ABpQRwF%2FVnQEKVJlUyVQeQRsATQIfgYhUy9QM1s%2BVShSOV8%2BUTEAZlI8VShVeldhUH0ObVtgVGQKYVUtAXMEZQBqUDwBalYxBGtSN1N8UHsEKgFgCCgGIVM4UD5bKFU3UjRfM1EsAGBSPFUzVXtXYVBiDmhbe1RzCmhVNwFrBGIAalA0AWVWPARiUjBTfFB7BDIBNQhiBmtTN1A1WzVVNFJgXzpRZgBnUjlVMFV7V2RQaw5nW2BUZQpsVTcBZQR4AHxQTQERVikEK1JyUzZQIgQqATQIaQZq&_c=dc7fd2774b0b3b7fd3a70bedbdd827ce")!
        }
    }
}

enum ServerResponses: Int {
    // bad key
    case badRequest = 400
    // too many requests
    case limitExceeded = 509
    // everything fine
    case valid = 200
    // server updating data
    case conflict = 409
}
