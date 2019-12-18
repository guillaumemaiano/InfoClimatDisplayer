//
//  AttributionCell.swift
//  WeatherDisplayerLBC
//
//  Created by guillaume MAIANO on 17/12/2019.
//  Copyright © 2019 guillaume MAIANO. All rights reserved.
//

import UIKit

/**
  Cell displays a simple text and allows opening a webview
 */

class AttributionCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textLabel?.text = "www.infoclimat.fr"
        self.textLabel?.textAlignment = .center
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func cellHeight() -> CGFloat {
        return CGFloat(Constants.UI.WeatherPredictionsTableCells.attributionHeight)
    }

}
