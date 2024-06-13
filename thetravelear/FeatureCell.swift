//
//  FeatureCell.swift
//  Travelear
//
//  Created by Nick Culpin on 12/24/19.
//  Copyright © 2019 thetravelear. All rights reserved.
//

import UIKit

class FeatureCell: BaseCollectionViewCell {
    
    let productLabel = TravelearLabel()
    
    override func setupViews() {
        addSubview(productLabel)
        productLabel.fillSuperview()
        productLabel.textAlignment = .center
        productLabel.font = UIFont.TravTitle()
    }
}
