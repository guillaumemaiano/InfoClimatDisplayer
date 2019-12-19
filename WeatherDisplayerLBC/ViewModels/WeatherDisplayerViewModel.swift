//
//  WeatherDisplayerViewModel.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

class WeatherDisplayerViewModel {
    
    private enum CellType {
        case prediction, information
    }
    
    enum WeatherDisplayerError: Error {
        case NonExistingSection
    }
    
    init() {
        // Improvement: switch location manager to make specific requests (see BoundTF)
        weatherManager = WeatherManager()
        weatherManager.errorClosure = errorFetchClosure
        weatherManager.weatherDataClosure = dataFetchClosure
        // will silently launch an initial update
        // there is a microscopic chance that the closure isn't yet set when it comes back
        // in that unlikely scenario, a manual request will trigger the display anyway
        weatherManager.getWeatherInformation() {
            
        }
    }
    
    private func dataFetchClosure() -> Void {
        // ONLY touch the data if a change hap
        var buildCellModelArray: [CellType: [WeatherDisplayCellViewModelProtocol]] = Dictionary()
        var buildPredictionArray: [WeatherDisplayCellViewModelProtocol] = []
        var cold = false
        var freezing = false
        for prediction in self.weatherManager.predictionData.sorted(by: { $0.0 < $1.0 }) {
            let groundTemperature = temperatureKelvinToCelsius(kelvin: prediction.value.temperature.sol)
            let groundTemperatureFormatted = WeatherDisplayerViewModel.temperatureFormatter(temperature: prediction.value.temperature.sol, from: .kelvin, to: .celsius)
            buildPredictionArray.append(WeatherCellViewModel(dateTime: prediction.key, temperature: "\(groundTemperatureFormatted) (au sol)", prediction: prediction.value))
            if groundTemperature < 10.0 {
                cold = true
                if groundTemperature < 0.0 {
                    freezing = true
                }
            }
        }
        buildCellModelArray[.prediction] = buildPredictionArray
        if cold {
            if freezing {
                // we have one warning only in this version
                buildCellModelArray[.information] = [InformationCellViewModel(title: "🧊 Be cautious 🧊", description: "Temperatures are below zero, roads may be iced over!", level: .warning)]
            } else {
                // we have one warning only in this version
                buildCellModelArray[.information] = [InformationCellViewModel(title: "🧥 Get a coat 🧥", description: "Temperatures are below 10°C, you might get a cold.", level: .info)]
            }
        }
        cellViewModels = buildCellModelArray
    }
    
    private func errorFetchClosure() -> Void {
        // 2 options to pass error up
        // bind an error var (but that's not fun)
        // insert / delete an error cell among the information cells
        var buildCellModelArray = cellViewModels
        if var infoArray = buildCellModelArray[.information] {
            for model in infoArray {
                if let info = model as? InformationCellViewModel {
                    // it's easier to just grab the few information messages than bother with making the model Equatable to indexAt/remove/insert new.
                    if info.level == .error {
                        let newErrorModel = InformationCellViewModel(title: "Incident",
                                                                     description: weatherManager.error?.localizedDescription ?? "L'application a rencontré un problème.",
                                                                     level: .error)
                        infoArray.append(newErrorModel)
                    } else {
                        infoArray.append(model)
                    }
                }
            }
            buildCellModelArray[.information] = infoArray
        }
    }
    
    
    private var cellViewModels: [CellType: [WeatherDisplayCellViewModelProtocol]] = Dictionary() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var weatherManager: WeatherManager
    var reloadTableViewClosure: (() -> ())?
    
    func getRows(for section: Int ) throws -> Int {
        
        if section == 0 {
            return cellViewModels[.prediction]?.count ?? 0
        } else if section == 1 {
            return cellViewModels[.information]?.count ?? 0
        } else {
            throw WeatherDisplayerError.NonExistingSection
        }
    }
    
    func getCellViewModel( at indexPath: IndexPath ) throws -> WeatherDisplayCellViewModelProtocol? {
        if indexPath.section == 0 {
            return cellViewModels[.prediction]?[indexPath.row]
        } else if indexPath.section == 1 {
            return cellViewModels[.information]?[indexPath.row]
        } else {
            throw WeatherDisplayerError.NonExistingSection
        }
    }
    
    func refresh() {
        weatherManager.getWeatherInformation() {
            // won't set if data has not changed, and we need to tell the UI to cut the refresh indicator
            self.reloadTableViewClosure?()
        }
    }
    
    // only the first section should transition
    // the second section doesn't ever
    // the third section has self-managing push
    func shouldTransition(for cellPathAt: IndexPath) -> Bool {
        if cellPathAt.section == 0 {
            return cellViewModels[.prediction]?[cellPathAt.row] != nil
        } else if cellPathAt.section == 2 {
            return true
        } else {
            return false
        }
    }
    
    static private let mf = MeasurementFormatter()
    
    static func temperatureFormatter(temperature: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
        WeatherDisplayerViewModel.mf.numberFormatter.maximumFractionDigits = 0
        WeatherDisplayerViewModel.mf.unitOptions = .providedUnit
        let input = Measurement(value: temperature, unit: inputTempType)
        let output = input.converted(to: outputTempType)
        return WeatherDisplayerViewModel.mf.string(from: output)
    }
    
    func temperatureKelvinToCelsius(kelvin: Double) -> Double {
        let kelvin = Measurement(value: kelvin, unit: UnitTemperature.kelvin)
        let celsius = kelvin.converted(to: .celsius)
        return celsius.value
    }
    
}
