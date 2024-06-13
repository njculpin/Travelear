//
//  CreatorProfileTitleTableViewCell.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/11/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class CreatorProfileTitleTableViewCell: UITableViewCell {
    
    lazy var trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 27.5
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var popOverTitleLabel = TravelearLabel()
    lazy var joinedDate = TravelearLabel()
    lazy var bioLabel = TravelearLabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews(){
        
        addSubview(popOverTitleLabel)
        addSubview(trackImageView)
        addSubview(joinedDate)
        addSubview(bioLabel)
        
        trackImageView.anchor(topAnchor, left: leftAnchor, bottom: popOverTitleLabel.topAnchor, right: nil, topConstant: 0, leftConstant: 22, bottomConstant: 22, rightConstant: 0, widthConstant: 55, heightConstant: 55)
        popOverTitleLabel.anchor(nil, left: leftAnchor, bottom: joinedDate.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 22, bottomConstant: 16, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        joinedDate.anchor(nil, left: leftAnchor, bottom: bioLabel.topAnchor, right: rightAnchor, topConstant: 24, leftConstant: 22, bottomConstant: 8, rightConstant: 22, widthConstant: 0, heightConstant: 16)
        bioLabel.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 16, leftConstant: 22, bottomConstant: 22, rightConstant: 22, widthConstant: 0, heightConstant: 0)
        
        popOverTitleLabel.font = UIFont.TravDemiLarge()
        joinedDate.font = UIFont.TravDemiSmall()
        bioLabel.font = UIFont.TravDemiSmall()
    }

}
