//
//  WeatherDisplayerCellViewModels.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 18/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

protocol WeatherDisplayCellViewModelProtocol {
    
}

struct WeatherCellViewModel: WeatherDisplayCellViewModelProtocol {
    let dateTime: String
    let temperature: String
    // pass the entire prediction (facilitate segue setup at the cost of minor duplication)
    let prediction: Prediction
    init(dateTime: String, temperature: String, prediction: Prediction) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let dateFormatterWeekday = DateFormatter()
        dateFormatterWeekday.dateFormat = "EEEE dd MMMM - HH:mm"
        dateFormatterWeekday.locale = Locale(identifier: Locale.preferredLanguages.first ?? Locale.current.identifier)
//        dateFormatterWeekday.dateStyle = .long
//        dateFormatterWeekday.timeStyle = .short
        
        var weekDate: String?
        if let date = dateFormatterGet.date(from: dateTime) {
            weekDate = dateFormatterWeekday.string(from: date)
            print(weekDate ?? "This should not happen")
        } else {
           print("There was an error decoding the string")
        }
        self.dateTime = weekDate ?? dateTime
        self.temperature = temperature
        self.prediction = prediction
    }
}

struct InformationCellViewModel: WeatherDisplayCellViewModelProtocol {
    let title: String
    let description: String
    let level: InfoLevel
    
}
