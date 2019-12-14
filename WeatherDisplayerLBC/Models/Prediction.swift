//
//  Prediction.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 13/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

// AFAIK, all data available through this site is actually NWS GFS Data, free for use thanks to the USA.
/**
 Eg: The Global Forecast System (GFS) is a weather forecast model produced by the National Centers for Environmental Prediction (NCEP). Dozens of atmospheric and land-soil variables are available through this dataset, from temperatures, winds, and precipitation to soil moisture and atmospheric ozone concentration. The entire globe is covered by the GFS at a base horizontal resolution of 18 miles (28 kilometers) between grid points, which is used by the operational forecasters who predict weather out to 16 days in the future. Horizontal resolution drops to 44 miles (70 kilometers) between grid point for forecasts between one week and two weeks. The GFS model is a coupled model, composed of four separate models (an atmosphere model, an ocean model, a land/soil model, and a sea ice model), which work together to provide an accurate picture of weather conditions. Changes are regularly made to the GFS model to improve its performance and forecast accuracy. This dataset is run four times daily at 00z, 06z, 12z and 18z out to 192 hours with a 0.5 degree horizontal resolution and a 3 hour temporal resolution.
 */
// This matters because all data transmitted is limited to the GFS-IC domain, which has a 15degree longitudinal span (-15 to 15) around Notre Dame de Paris and a [34.7534 - 55.2] longitudinal range.
// Note: it's a huge zone, extending into the Baltic sea, the Mediterranean further than Malta, and deep into the Altantic.
// A consequence though, is that the UI must warn the user if he's moving out of the region: displaying data for Paris.
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
