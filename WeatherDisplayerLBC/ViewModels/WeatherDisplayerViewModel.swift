//
//  WeatherDisplayerViewModel.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

class WeatherDisplayerViewModel {
    
    static private let mf = MeasurementFormatter()
    
    private enum CellType {
        case prediction, information
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
        var buildInformationModelArray: [WeatherDisplayCellViewModelProtocol] = []
        if cold {
            if freezing {
                buildInformationModelArray.append( InformationCellViewModel(title: "🧊 Be cautious 🧊", description: "Temperatures are below zero, roads may be iced over!", level: .warning))
            } else {
                buildInformationModelArray.append( InformationCellViewModel(title: "🧥 Get a coat 🧥", description: "Temperatures are below 10°C, you might get a cold.", level: .info))
            }
        }
        for information in informationArray {
            buildInformationModelArray.append( InformationCellViewModel(title: information.0, description: information.1, level: .info))
        }
        buildCellModelArray[.information] = buildInformationModelArray
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
    
    private func updateLocationDisplay(location: String) {
        
    }
    
    private var informationArray: [(String, String)] = Array()
    
    private var cellViewModels: [CellType: [WeatherDisplayCellViewModelProtocol]] = Dictionary() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }

    // MARK: - Properties
    var weatherManager: WeatherManager
    var reloadTableViewClosure: (() -> ())?
    
    // MARK: - Methods

    init() {
        // Improvement: switch location manager to make specific requests (see BoundTF)
        let predictionManager = PredictionManager()
        let locationManagerDelegate = MapManagerDelegate(didUpdateLocation: {
            locationString in print("Updated location to \(predictionManager.changeLocation(location: locationString) ?? " no location").")
        })
        let locationManager = MapManager(delegate: locationManagerDelegate)
        weatherManager = WeatherManager(predictionManager: predictionManager, locationManager: locationManager)
        weatherManager.errorClosure = errorFetchClosure
        weatherManager.weatherDataClosure = dataFetchClosure
        // will silently launch an initial update
        // there is a microscopic chance that the closure isn't yet set when it comes back
        // in that unlikely scenario, a manual request will trigger the display anyway
        weatherManager.getWeatherInformation() {
            
        }
    }
    
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
    
    func temperatureKelvinToCelsius(kelvin: Double) -> Double {
        let kelvin = Measurement(value: kelvin, unit: UnitTemperature.kelvin)
        let celsius = kelvin.converted(to: .celsius)
        return celsius.value
    }
    
    // MARK: - static properties
    
    static func temperatureFormatter(temperature: Double, from inputTempType: UnitTemperature, to outputTempType: UnitTemperature) -> String {
        WeatherDisplayerViewModel.mf.numberFormatter.maximumFractionDigits = 0
        WeatherDisplayerViewModel.mf.unitOptions = .providedUnit
        let input = Measurement(value: temperature, unit: inputTempType)
        let output = input.converted(to: outputTempType)
        return WeatherDisplayerViewModel.mf.string(from: output)
    }
    
    // MARK: - Member public enums
    enum WeatherDisplayerError: Error {
        case NonExistingSection
    }
}
