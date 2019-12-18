//
//  InformationCell.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit

class InformationCell: UITableViewCell {
    
    private var infoLevel: InfoLevel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textLabel?.textAlignment = .center
        self.selectionStyle = .none
        switch infoLevel {
        case .error:
            self.backgroundColor = UIColor.red.withAlphaComponent(0.90)
        case .warning:
            self.backgroundColor = UIColor.green.withAlphaComponent(0.80)
        case .info:
            self.backgroundColor = UIColor.systemGray.withAlphaComponent(0.70)
        default:
            break
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

enum InfoLevel {
    case error, info, warning
}
