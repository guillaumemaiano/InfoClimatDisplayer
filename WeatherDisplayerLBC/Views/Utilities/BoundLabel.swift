//
//  BoundLabel.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 19/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import Foundation
import UIKit

class BoundLabel: UILabel {
    
    func bind(to observable: Observable<String>) {
        observable.valueChanged = { [weak self] newValue in
            DispatchQueue.main.async {
               self?.text = newValue
            }
        }
    }
}
