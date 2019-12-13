//
//  WeatherRouter.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 12/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation
// class because weatherData/error can be mutated, and completionHandler is escaping
class WeatherRouter {
    var url: URL
    private(set) var weatherData: String = ""
    private(set) var error:  Error? = nil
    
    init(url: URL) {
        self.url = url
    }
    
    func fetch(using session: URLSessionProtocol = URLSession.shared,
               completionHandler: @escaping () -> Void) {
        let task = session.dataTask(with: url) {
                   data, response, error in
                   if let data = data {
                       self.weatherData = String(decoding: data, as: UTF8.self)
                   }
                   self.error = error
                   completionHandler()
               }
               task.resume()
    }
}

// protocol for mocking URLSession
protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

// extension to backport the mockable protocol
extension URLSession: URLSessionProtocol {
    
}
