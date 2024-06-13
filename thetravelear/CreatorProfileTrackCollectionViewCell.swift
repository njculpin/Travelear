//
//  CreatorProfileTrackCollectionViewCell.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/11/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class CreatorProfileTrackCollectionViewCell: BaseCollectionViewCell {
    
    let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func setupViews() {
        addSubview(trackImageView)
        trackImageView.fillSuperview()
    }
    
    var track: Track! {
        didSet {
            self.updateUI()
            self.setNeedsLayout()
        }
    }
    
    
    func updateUI(){
        trackImageView.image = UIImage(imageLiteralResourceName: "cell-placeholder")
        let imageURL = URL(string:track.image!)
        DispatchQueue.main.async(execute: {
            self.trackImageView.sd_setImage(with: imageURL, placeholderImage:#imageLiteral(resourceName: "cell-placeholder"), options: [.continueInBackground])
        })
        trackImageView.isAccessibilityElement = false
    }
}
