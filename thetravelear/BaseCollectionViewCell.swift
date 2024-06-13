//
//  BaseCell.swift
//  Travelear
//
//  Created by Nicholas Culpin on 6/17/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.backgroundColor = UIColor.gray
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.main.bounds.size.width
        contentView.widthAnchor.constraint(equalToConstant: screenWidth - ( 3 * 12 )).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
