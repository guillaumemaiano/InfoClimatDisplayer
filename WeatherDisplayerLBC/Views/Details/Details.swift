//
//  Details.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 18/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit

// display class where all elements are statically set
// However, future proofed by making labels MVVM nonetheless
class DetailsViewController: UIViewController {
    
    var viewModel: DetailsViewModel?

    // temperatures at various pressure levels
    @IBOutlet weak var twoMeterLevelTemperature: BoundLabel!
    @IBOutlet weak var groundTemperature: BoundLabel!
    @IBOutlet weak var fiveHundredHpaTemperature: BoundLabel!
    @IBOutlet weak var eightFiftyHpaTemperature: BoundLabel!
    
    // regional rain
    @IBOutlet weak var rain: BoundLabel!
    // environment induced rain
    @IBOutlet weak var convectiveRain: BoundLabel!
    // pressure & humidity
    @IBOutlet weak var humidity: BoundLabel!
    @IBOutlet weak var pressure: BoundLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let model = viewModel {
            groundTemperature.bind(to: model.groundTemperature)
            twoMeterLevelTemperature.bind(to: model.twoMeterLevelTemperature)
            fiveHundredHpaTemperature.bind(to: model.fiveHundredHpaTemperature)
            eightFiftyHpaTemperature.bind(to: model.eightFiftyHpaTemperature)
            rain.bind(to: model.rain)
            convectiveRain.bind(to: model.convectiveRain)
            humidity.bind(to: model.humidity)
            pressure.bind(to: model.pressure)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        viewModel?.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.setup()
    }
    
}
