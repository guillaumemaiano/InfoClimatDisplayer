//
//  WeatherStore.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation
struct WeatherStore {
    
    static let nameString = "latestWeatherData"
    
    let customPathString: String?
    
    // requires a valid path String
    init(pathString: String? = nil) {
        customPathString = pathString
    }
    
    // create a file and write data to it
    // CoreData/Realm sounds overkill
    func storeData(dataString: String, completionHandler: @escaping () -> Void) {
        do {
            // if custom path not passed in check the standard folder
            // if failure, bail silently
            let fileManager = FileManager.default
            var documentsURL: URL?
            if let customPath = customPathString {
                documentsURL = URL(fileURLWithPath: customPath)
            } else {
                documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            }
            if let documentsURL = documentsURL {
                let dataURL = documentsURL.appendingPathComponent(WeatherStore.nameString)
                try dataString.write(to: dataURL, atomically: true, encoding: .utf8)
            }
            
        } catch let error {
            print("error: \(error)")
        }
        completionHandler()
    }
    
    // read data back
    func readData(completionHandler: @escaping (String?) -> Void) {
        // if custom path not passed in check the standard folder
        // if failure, bail silently
        let fileManager = FileManager.default
        var documentsURL: URL?
        if let customPath = customPathString {
            documentsURL = URL(fileURLWithPath: customPath)
        } else {
            documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        }
        do {
            if let documentsURL = documentsURL {
                let dataURL = documentsURL.appendingPathComponent(WeatherStore.nameString)
                if fileManager.fileExists(atPath: dataURL.path) {
                    let input = try String(contentsOf: dataURL)
                    completionHandler(input)
                } else {
                    completionHandler(nil)
                }
                
            }
            
        } catch let error {
            print("error: \(error)")
        }
    }
}
