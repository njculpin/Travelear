//
//  BannerAdCell.swift
//  Travelear
//
//  Created by Nick Culpin on 2/11/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation

import UIKit

class BannerAdCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
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
