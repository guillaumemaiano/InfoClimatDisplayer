//
//  Prediction.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 13/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

struct Prediction: Codable, Equatable {
    // quick rundown of retrieved data structure
    // ignore the first 5 keys, they're irrelevant to the end user
    
    //    var requestState: Int?
    //    var requestKey: String?
    //    var message: String?
    //    var modelRun: Int?
    // internal GFS 1, because none of the other data sources can't be shared with the general public
    // according to website T&C
    //    var source: String?
    
    // -> This part makes the use of Codable more complex than I'd like if trying to grab the whole JSON as an object
    // easier imho: strip it with JSONSerialization within the retrieval code
    // and build our own array of Codable-compliant elements, see PredictionManager
    //    "2019-12-09 04:00:00": {
    //      complex content, see below for example
    //     }
    
    //     Example of content within the data elements:
    //     "temperature": {
    //         "2m": 277.7,
    //         "sol": 278.2,
    //         "500hPa": -0.1,
    //         "850hPa": -0.1
    //     },
    //     "pression": {
    //         "niveau_de_la_mer": 100620
    //     },
    //     "pluie": 0,
    //     "pluie_convective": 0,
    //     "humidite": {
    //         "2m": 77.8
    //     },
    // ignore all other keys, I won't display or store them
    //     "vent_moyen": {
    //         "10m": 16.2
    //     },
    //     "vent_rafales": {
    //         "10m": 40
    //     },
    //     "vent_direction": {
    //         "10m": 266
    //     },
    //     "risque_neige": "non",
    //     "iso_zero": 850,
    //     "cape": 0,
    //     "nebulosite": {
    //         "haute": 0,
    //         "moyenne": 33,
    //         "basse": 2,
    //         "totale": 33
    //     }
    
    var temperature: Temperature
    var pluie: Double
    var pluieConvective: Double
    var pression: Pression
    var humidite: Humidite
    // Any? prevents Equatable
    var ventMoyen: String?
    var ventRafale: String?
    var ventDirection: String?
    var isoZero: String?
    var risqueNeige: String?
    var cape: String?
    var nebulosite: String?
    
    // Var not enumerated in coding keys are ignored for decoding and encoding
    private enum CodingKeys: String, CodingKey {
        case temperature,
        pluie,
        pluieConvective,
        pression,
        humidite
    }
}

struct Humidite: Codable, Equatable {
    // note: Double is actually incorrect, since it has a different precision
    // on the other hand, building custom deserializers for every element defeats the purpose of Codable
    var twoMeterHeightMeasure: Double
    enum CodingKeys: String, CodingKey {
        case twoMeterHeightMeasure = "2m"
    }
}

struct Temperature: Codable, Equatable {
    // same note
    var sol: Double
    var twoMeterHeightMeasure: Double
    var halfkhPa: Double
    var eightHundredFiftyhPa: Double
    
    enum CodingKeys: String, CodingKey {
        case twoMeterHeightMeasure = "2m"
        case sol = "sol"
        case halfkhPa = "500hPa"
        case eightHundredFiftyhPa = "850hPa"
    }
    
}

struct Pression: Codable, Equatable {
    var niveauDeLaMer: Int
}
