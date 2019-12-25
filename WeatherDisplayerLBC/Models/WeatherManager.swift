//
//  WeatherManager.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 13/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

// I want a class so I may bind vars
class WeatherManager {
    
    // MARK: - Private
    private let predictionManager: PredictionManager
    private let locationManager: MapManagerProtocol
    
    // MARK: - Functions
    // Passing the map manager in allows better unit testing
    init(predictionManager: PredictionManager = PredictionManager(), locationManager: MapManagerProtocol = MapManager(delegate:
        MapManagerDelegate(didUpdateLocation: { locationString in
            print("Pass location string \(locationString) to prediction manager")
        }))) {
        self.locationManager = locationManager
        self.predictionManager = predictionManager
        predictionData = [:]
    }
    
    var errorClosure: (() -> Void)?
    var weatherDataClosure: (() -> Void)?
    
    private (set) var predictionData: [String: Prediction] {
        didSet {
            weatherDataClosure?()
        }
    }
    
    private (set) var error: Error?  = nil {
        didSet {
            errorClosure?()
        }
    }
    
    // Note: completionHandler useful for async unit tests (fulfill)
     func getWeatherInformation(completionHandler: (() -> Void)? = nil) {
        
        // only request data if necessary
        if predictionManager.needsRefresh {
            predictionManager.requestUpdate() {
                data, error in
                if let data = data {
                    // extract the data from the response
                    self.predictionData = self.predictions(from: data)
                    completionHandler?()
                } else if let error = error {
                    self.error = error
                    print(error)
                }
            }
        } else {
            completionHandler?()
            print("No need, data up to date")
        }
    }
    
    private func predictions(from data: String?) -> [String:Prediction] {
        
        // We get a string containing a JSON array of datetime:prediction, parse it and be golden
        guard let weatherData = data?.data(using: .utf8) else {
            return [:]
        }
        return extractPredictionArray(data: weatherData)
    }
    
    private func extractPrediction(predictionData: Data) throws -> Prediction {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let prediction: Prediction = try decoder.decode(Prediction.self, from: predictionData)
            return prediction
            
        } catch {
            print("\n\nPrediction was not extracted correctly from \(String(data: predictionData,encoding: .utf8) ?? "** Data could not be converted **")")
            throw error
        }
    }
    // JSONSerialization.jsonObject gives an array of dictionaries I could parse per key
    // however that doesn't leverage Codable
    // conversions are cheap, hence I'll convert and cast
    private func extractPredictionArray(data: Data) -> Dictionary<String, Prediction> {
        var predictionDict = Dictionary<String, Prediction>()
        do {
            
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any] {
                for (jsonRootKey, jsonRootContent) in dictionary {
                    guard let rootData = try? JSONSerialization.data(withJSONObject: jsonRootContent,
                                                                     options: [.prettyPrinted]) else {
                                                                        print("Reserialization of stem failure")
                                                                        break
                    }
                    
                    // convert root content to Prediction
                    let prediction = try extractPrediction(predictionData: rootData)
                    predictionDict[jsonRootKey] = prediction
                }
            }
        } catch let conversionError {
            print(conversionError.localizedDescription)
        }
        return predictionDict
    }
}

protocol WeatherManagerDelegate {
    func didUpdateLocation(predictionLocation: String)
}

struct WMDelegate: WeatherManagerDelegate {
    
    private let predictionManager: PredictionManager

    init(manager: PredictionManager) {
        predictionManager = manager
    }
    func didUpdateLocation(predictionLocation: String) {
        let _ = predictionManager.changeLocation(location: predictionLocation)
    }
}
