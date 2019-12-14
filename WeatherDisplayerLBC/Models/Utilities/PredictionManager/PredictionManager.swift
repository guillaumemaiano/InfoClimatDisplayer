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
    // no point pulling CLLocation here
    private var location: String? = nil
    
    // constants for readability
    private static let LATITUDE: String = LL.latitude.rawValue
    private static let LONGITUDE: String = LL.longitude.rawValue
    private enum LL: String {
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    private struct GFSIC_Domain {
        static let maximumLatitude: Double = 55.2
        static let minimumLatitude: Double = 34.7534
        static let maximumLongitude: Double = 15.0
        static let minimumLongitude: Double = -15
    }
    
    // under no circumstance add option s to the pattern specifier
    // it would turn the latitude minute separator (the dot) in a line terminator matcher
    // http://userguide.icu-project.org/strings/regexp
    private static let pattern = #"""
    (?xi)
    (?<\#(LATITUDE)> ([0-9]{1,2}[.][0-9]{0,5}))
    [,]
    (?<\#(LONGITUDE)> ([-]?[0-9]{1,2}[.][0-9]{0,5}))
    """#
    
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
        let router = WeatherRouter(url: Constants.Endpoint.weatherServer(ll: location))
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
    
    func changeLocation(location: String) -> String? {
        
        // reset before we do anything
        self.location = nil
        // This matters because all data transmitted is limited to the GFS-IC domain, which has a 15degree longitudinal span (-15 to 15) around Notre Dame de Paris and a [34.7534 - 55.2] longitudinal range.
        // validate the string with a basic pattern: "[0-9]{1,2}.[0-9]{,5},[0-9]{1,2}.[0-9]{,5}"
        do {
            let regex = try NSRegularExpression(pattern: Self.pattern)
            let nsrange = NSRange(location.startIndex..<location.endIndex,
                                  in: location)
            if let match = regex.firstMatch(in: location,
                                            options: [],
                                            range: nsrange)
            {
                var hasLatitudeIssue = false
                var hasLongitudeIssue = false
                for component in [Self.LATITUDE, Self.LONGITUDE] {
                    let nsrange = match.range(withName: component)
                    if nsrange.location != NSNotFound,
                        let range = Range(nsrange, in: location)
                    {
                        // debug
                        print("\(component): \(location[range])")
                        // 0.0 to avoid potential linting nagging
                        // we know it's valid because we're using a match result
                        let locationElement: Double = Double(String(location[range])) ?? 0.0
                        switch component {
                        case Self.LATITUDE:
                            if locationElement < GFSIC_Domain.maximumLatitude // not further than Poland
                                && locationElement > GFSIC_Domain.minimumLatitude // mid-Atlantic
                            {
                                print("we're within the information-rich latitudes")
                            } else
                            {
                                // we're out of the GFS-IC zone, we'll reset location
                                hasLatitudeIssue = true
                            }
                        case Self.LONGITUDE:
                            if locationElement > GFSIC_Domain.minimumLongitude // mid Baltic Sea
                                && locationElement < GFSIC_Domain.maximumLongitude // further than Malta
                            {
                                print("we're within the information-rich longitudes")
                            } else
                            {
                                // we're out of the GFS-IC zone, we'll reset location
                                hasLongitudeIssue = true
                            }
                        default:
                            fatalError("Failure, regexp yielded unknown component, but matcher wasn't updated!")
                        }
                    }
                }
                // if out of the GFS-IC domain, reset
                if hasLatitudeIssue || hasLongitudeIssue {
                    print("\n\n⚠️\nnot within domain\n latitude issue: \(hasLatitudeIssue), longitude issue:\(hasLongitudeIssue)\n\n")
                }
                // if within the GFS-IC domain, assign
                else {
                    self.location = location
                }
            }
        } catch {
            print("Hardcoded regexp invalid. Programmer needs coffee.")
        }
        return self.location
    }
    
    /**
     Testing requires the ability to reset.
     */
    func forceReset() {
        lastRefreshDate = nil
    }
}
