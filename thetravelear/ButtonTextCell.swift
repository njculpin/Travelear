//
//  ButtonTextCell.swift
//  Travelear
//
//  Created by Nick Culpin on 2/19/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation

class ButtonTextCell: UITableViewCell {

    let buttonTextLabel = TravelearLabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(buttonTextLabel)
        buttonTextLabel.font = UIFont.TravRegular()
        buttonTextLabel.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
