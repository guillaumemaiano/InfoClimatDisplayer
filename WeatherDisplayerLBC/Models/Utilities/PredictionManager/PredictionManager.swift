//
//  PredictionManager.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

class PredictionManager {
    // MARK: - Private
    private let store = WeatherStore()
    private var lastRefreshDate: Date?
    // 5 minutes are an acceptable staleness duration
    private let staleInterval: TimeInterval = 300
    private var isUpdating: Bool = false
    
    // MARK: - Properties
    static let shared = PredictionManager()
    
    var needsRefresh: Bool {
        get {
            if let refreshDate = lastRefreshDate {
                let staleDate = refreshDate.addingTimeInterval(staleInterval)
                let currentDate = Date()
                // data isn't stale yet
                return currentDate > staleDate
            } else {
                return true
            }
        }
    }
    
    private init() {
    }
    
    // MARK: - Methods
    func requestUpdate( completionHandler: @escaping (String?, Error?) -> Void) {
        if !isUpdating {
            isUpdating.toggle()
            // check if we have up-to-date data on disk
            let store = WeatherStore()
            store.readData() {
                contents in
                if let content: String = contents {
                    let decoder = PredictionsStoreDecoder()
                    if let jsonPredictions = try? decoder.decode(PredictionStore.self, from: content.data(using: .utf8)!) {
                        print("----\(Date())\n----\(jsonPredictions.requestDate)\n--->\(jsonPredictions.prediction)\n")
                        self.lastRefreshDate = jsonPredictions.requestDate
                        print("\(Date().debugDescription)\n \(self.lastRefreshDate.debugDescription)")
                        if self.needsRefresh {
                            self.refreshData(store: store, completionHandler: completionHandler)
                        } else {
                            // we have valid data on disk!
                            completionHandler(jsonPredictions.prediction, nil)
                            self.isUpdating.toggle()
                        }
                        
                    } else {
                        // content could not be converted to a correct JSON, refresh it
                        self.refreshData(store: store, completionHandler: completionHandler)
                    }
                    
                } else {
                    // content could not be parsed properly, refresh it
                    self.refreshData(store: store, completionHandler: completionHandler)
                }
            }
        } else {
            // we're already running a request
            completionHandler(nil, PredictionError.inProgress)
        }
    }
    
    private func refreshData(store: WeatherStore,
                             completionHandler: @escaping (String?, Error?) -> Void) {
        let router = WeatherRouter(url: Constants.Endpoint.weatherServer())
        router.fetch {
            if let data: Data = router.weatherData.data(using: .utf8) {
                self.verifyRequest(data: data) {
                    data, verificationError in
                    // if everything went fine, attempt to write to disk and pass the data to the requester
                    if let verifiedData = data {
                        let encoder = PredictionsStoreEncoder()
                        // extract the useful information before actual disk write
                        let predictions = PredictionStore(requestDate: Date(),
                                                          prediction: self.extractPrediction(data: verifiedData.data(using: .utf8)!))
                        do {
                            // always stop updating after this step, whether or not it wrote to disk
                            defer {
                                self.isUpdating = false
                            }
                            let contents = try encoder.encode(predictions)
                            store.storeData(dataString: String(data: contents, encoding: .utf8) ?? "") {
                                self.lastRefreshDate = predictions.requestDate
                                completionHandler(String(data: contents, encoding: .utf8) ?? "", nil)
                            }
                            
                        } catch let storageError {
                            completionHandler(nil, storageError)
                            self.lastRefreshDate = nil
                        }
                    } else {
                        // else pass the error to the requester (writing nil explicitly for readability)
                        completionHandler(nil, verificationError)
                    }
                }
            } else {
                // request failed, router responded with an error (not in the JSON, an actual network error)
                completionHandler(nil, router.error)
                self.lastRefreshDate = nil
                self.isUpdating = false
            }
        }
    }
    
    private func verifyRequest(data: Data, completionHandler: @escaping (String?, Error?) -> Void) {
        // check request state
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dictionary = json as? [String: Any] {
            if let requestState = dictionary["request_state"] as? Int {
                switch requestState {
                case ServerResponses.valid.rawValue:
                    // carry on
                    completionHandler(String(data: data, encoding: .utf8) ?? "", nil)
                case ServerResponses.conflict.rawValue:
                    completionHandler(nil, PredictionError.serverUpdating)
                    // UI needs to schedule some request for later on
                    lastRefreshDate = nil
                    isUpdating = false
                case ServerResponses.limitExceeded.rawValue:
                    completionHandler(nil, PredictionError.serverLimitExceeded)
                    // UI needs to schedule some request for much later on
                    lastRefreshDate = nil
                    isUpdating = false
                case ServerResponses.badRequest.rawValue:
                    completionHandler(nil, PredictionError.badRequest)
                    // UI can't do anything - tell user the app needs an update
                    lastRefreshDate = nil
                    isUpdating = false
                default:
                    completionHandler(nil, PredictionError.invalidStatus)
                    // UI can't do anything - tell user the app needs an update
                    lastRefreshDate = nil
                    isUpdating = false
                }
            }
        }
    }
    
    // strip the JSON received from the server from the data I don't need
    // see PredictionStore for details
    private func extractPrediction(data: Data) -> String {
        var strippedJSONString = "{}"
        do {
            let predictionDict = NSMutableDictionary()
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let dictionary = json as? [String: Any] {
                for (jsonRootKey, jsonRootContent) in dictionary {
                    switch jsonRootKey {
                    case "request_state",
                         "request_key",
                         "message",
                         "model_run",
                         "source":
                        break
                    // actual content I care about
                    default:
                        predictionDict.setValue(jsonRootContent, forKey: jsonRootKey)
                    }
                }
            }
            if let backToData = try?  JSONSerialization.data(
                withJSONObject: predictionDict,
                options: []
                ),
                let validString = String(data: backToData,
                                         encoding: String.Encoding.ascii) {
                    strippedJSONString = validString
              }
        } catch let conversionError {
            print(conversionError.localizedDescription)
        }
        return strippedJSONString
    }
    
       /**
            Testing requires the ability to reset.
        */
       func forceReset() {
           lastRefreshDate = nil
       }
}
