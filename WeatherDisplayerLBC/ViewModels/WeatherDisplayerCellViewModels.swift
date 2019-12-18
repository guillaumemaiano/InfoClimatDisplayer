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
}

struct InformationCellViewModel: WeatherDisplayCellViewModelProtocol {
    let title: String
    let description: String
}
