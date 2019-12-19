//
//  DetailsViewModel.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 19/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

struct DetailsViewModel {
    let prediction: Prediction
    
    let twoMeterLevelTemperature = Observable("")
    let groundTemperature = Observable("")
    let fiveHundredHpaTemperature = Observable("")
    let eightFiftyHpaTemperature = Observable("")
    let rain = Observable("")
    let convectiveRain = Observable("")
    let humidity = Observable("")
    let pressure = Observable("")
    
    func setup() {
        // temperatures
        var temperature = WeatherDisplayerViewModel.temperatureFormatter(temperature: prediction.temperature.twoMeterHeightMeasure, from: .kelvin, to: .celsius)
        twoMeterLevelTemperature.value = "(2m): \(temperature)"
        
        temperature = WeatherDisplayerViewModel.temperatureFormatter(temperature: prediction.temperature.sol, from: .kelvin, to: .celsius)
        groundTemperature.value = "(sol): \(temperature)"
        
        temperature = WeatherDisplayerViewModel.temperatureFormatter(temperature: prediction.temperature.halfkhPa, from: .kelvin, to: .celsius)
        fiveHundredHpaTemperature.value = "(500hPa): \(temperature)"
        
        temperature = WeatherDisplayerViewModel.temperatureFormatter(temperature: prediction.temperature.eightHundredFiftyhPa, from: .kelvin, to: .celsius)
        eightFiftyHpaTemperature.value = "(850hPa): \(temperature)"

        // rain-related
        rain.value = "Pluie: \(prediction.pluie) %"
        convectiveRain.value = "Pluie convective: \(prediction.pluieConvective) %"
        humidity.value = "Humidité: \(prediction.humidite.twoMeterHeightMeasure) %"
        pressure.value = "Pression au niveau de la mer:\n \(prediction.pression.niveauDeLaMer) hPa"
    }
}
