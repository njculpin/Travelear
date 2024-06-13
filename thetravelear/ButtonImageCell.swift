//
//  ButtonImageCell.swift
//  Travelear
//
//  Created by Nick Culpin on 2/19/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation

class ButtonImageCell: UITableViewCell {

    let buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(buttonImageView)
        buttonImageView.fillSuperview()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
