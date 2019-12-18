//
//  Details.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 18/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    // temperatures at various pressure levels
    @IBOutlet weak var twoMeterLevelTemperature: UILabel!
    @IBOutlet weak var groundTemperature: UILabel!
    @IBOutlet weak var fiveHundredHpaTemperature: UILabel!
    @IBOutlet weak var eightFiftyHpaTemperature: UILabel!
    
    // regional rain
    @IBOutlet weak var rain: UILabel!
    // environment induced rain
    @IBOutlet weak var convectiveRain: UILabel!
    // pressure & humidity
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var pressure: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
