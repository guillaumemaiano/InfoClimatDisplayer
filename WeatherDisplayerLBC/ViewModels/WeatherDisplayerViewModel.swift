//
//  WeatherDisplayerViewModel.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation

struct WeatherDisplayerViewModel {
    
    private enum CellType {
        case prediction, information
    }
    
    enum WeatherDisplayerError: Error {
        case NonExistingSection
    }
    
    init() {
        // Improvement: switch location manager to make specific requests (see BoundTF)
        weatherManager = WeatherManager()
        // will silently launch an initial update
        // there is a microscopic chance that the closure isn't yet set when it ccomes back
        // in that unlikely scenario, a manual request will trigger the display anyway
        weatherManager.getWeatherInformation()
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
    
}
