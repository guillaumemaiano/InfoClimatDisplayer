//
//  PredictionTests.swift
//  WeatherDisplayerLBCTests
//
//  Created by guillaume MAIANO on 13/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import XCTest
@testable import WeatherDisplayerLBC

class PredictionTests: XCTestCase {

    func testWeatherGrabber_Prediction_Creation() {
        // given
        guard let predictionData = #"{"temperature":{"2m":280.7,"sol":282.4,"500hPa":-0.1,"850hPa":-0.1},"pression":{"niveau_de_la_mer":98220},"pluie":0.8,"pluie_convective":0.4,"humidite":{"2m":66},"vent_moyen":{"10m":32.9},"vent_rafales":{"10m":67.4},"vent_direction":{"10m":285},"iso_zero":938,"risque_neige":"non","cape":0,"nebulosite":{"haute":0,"moyenne":55,"basse":96,"totale":99}}"#.data(using: .utf8)
        else {
            XCTFail("Buggy test, data incorrect")
            return
        }
        let temp = Temperature(sol: 282.4, twoMeterHeightMeasure: 280.7, halfkhPa: -0.1, eightHundredFiftyhPa: -0.1)
        let pression = Pression(niveauDeLaMer: 98220)
        let humidite = Humidite(twoMeterHeightMeasure: 66)
        let predictionReference = Prediction(temperature: temp,
                                             pluie: 0.8,
                                             pluieConvective: 0.4,
                                             pression: pression,
                                             humidite: humidite,
                                             // all other keys should be ignored and the objects be Equal
                                             ventMoyen: nil,
                                             ventRafale: nil,
                                             ventDirection: nil,
                                             isoZero: nil,
                                             risqueNeige: nil,
                                             cape: nil,
                                             nebulosite: nil)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // when
        do {
            let prediction: Prediction = try decoder.decode(Prediction.self, from: predictionData)
            
            // then
            XCTAssertEqual(prediction, predictionReference)
        } catch {
            XCTFail("Prediction creation failed \(error)")
        }
    }
    
    // I'd like to ensure it runs smoothly, though it's unlikely I'll need it
    func testWeatherGrabber_Pression_Consumption() {
        // given
        let seaLevelPressure: Int = 98220
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        // when
        do {
            let pressionJSON = try encoder.encode(Pression(niveauDeLaMer: seaLevelPressure))
            print("\nPression JSON: \(String(data: pressionJSON, encoding: .utf8) ?? "")")
        } catch {
            // then
            XCTFail("\n Bad translation to JSON Data: \(error)")
        }
    }
    
    func testWeatherGrabber_Pression_Creation() {
        // given
        let seaLevelPressure: Int = 98220
        //        guard let pressionJSON = #"{"pression":{"niveau_de_la_mer":\#(seaLevelPressure)}}"#.data(using: .utf8) else {
        //            XCTFail("Buggy test, data incorrect")
        //            return
        //        }
        guard let pressionJSON = #"{"niveau_de_la_mer":\#(seaLevelPressure)}"#.data(using: .utf8) else {
            XCTFail("Buggy test, data incorrect")
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // when
        do {
            let pression: Pression = try decoder.decode(Pression.self, from: pressionJSON)
            
            // then
            XCTAssertEqual(pression, Pression(niveauDeLaMer: seaLevelPressure))
        } catch {
            XCTFail("Pression creation failed \(error)")
        }
    }
    
    func testWeatherGrabber_Temperature_Creation() {
        // given
        let temperatures = ["2m" : 280.7,"sol" : 282.4,"500hPa" : -0.1,"850hPa" : -0.1]
        // {"temperature":{"2m":280.7,"sol":282.4,"500hPa":-0.1,"850hPa":-0.1}}"
        guard let temperatureJSON = """
            {"2m":\(temperatures["2m"]!),
            "sol":\(temperatures["sol"]!),
            "500hPa":\(temperatures["500hPa"]!),
            "850hPa":\(temperatures["850hPa"]!),
            }
            """.data(using: .utf8) else {
                XCTFail("Buggy test, data incorrect")
                return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // when
        do {
            let temperature: Temperature = try decoder.decode(Temperature.self, from: temperatureJSON)
            
            // then
            XCTAssertEqual(temperature, Temperature(sol: temperatures["sol"]!,
                                                        twoMeterHeightMeasure: temperatures["2m"]!,
                                                        halfkhPa: temperatures["500hPa"]!,
                                                        eightHundredFiftyhPa: temperatures["850hPa"]!))
        }  catch {
            XCTFail("Temperature creation failed \(error)")
        }
    }
    
    func testWeatherGrabber_Humidite_Creation() {
        // given
        let humidityTwoMeter = 66.9
        // "{"humidite":{"2m":66.9}}"
        guard let humidJSON = #"{"2m":\#(humidityTwoMeter)}"#.data(using: .utf8) else {
            XCTFail("Buggy test, data incorrect")
            return
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // when
        do {
            let humidite: Humidite = try decoder.decode(Humidite.self, from: humidJSON)

            // then
            XCTAssertEqual(humidite, Humidite(twoMeterHeightMeasure: humidityTwoMeter))
        } catch {
            XCTFail("Humidite creation failed \(error)")
        }
    }
}
