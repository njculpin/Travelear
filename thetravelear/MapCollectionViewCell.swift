//
//  MapCollectionViewCell.swift
//  Travelear
//
//  Created by Nicholas Culpin on 10/22/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class MapCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: DRAW
    override func setupViews() {
        addSubview(trackImageView)
        addSubview(darkLayer)
        addSubview(stackView)
        addSubview(favoriteButton)
        stackView.addArrangedSubview(lockImage)
        stackView.addArrangedSubview(trackNameLabel)
        stackView.addArrangedSubview(locationLabel)
        
        trackImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        darkLayer.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        stackView.rightAnchor.constraint(equalTo: favoriteButton.leftAnchor, constant: 32).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 32).isActive = true
        stackView.anchorCenterYToSuperview()
        favoriteButton.anchor(topAnchor, left: stackView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 32, widthConstant: 44, heightConstant: 44)
        
        lockImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lockImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
    }

        var delegate: ListCellDelegate?
        var isDownloaded = Bool()
        lazy var trackNameLabel = TravelearLabelPadded()
        lazy var locationLabel = TravelearLabelPadded()

        lazy var favoriteButton: UIButton = {
            let sb = UIButton()
            sb.setImage(UIImage(named: "favorite"), for: .normal)
            sb.isAccessibilityElement = true
            sb.accessibilityLabel = "More Context"
            return sb
        }()

        lazy var stackView: UIStackView = {
            let stack = UIStackView()
            stack.axis = NSLayoutConstraint.Axis.vertical
            stack.distribution = UIStackView.Distribution.equalSpacing
            stack.spacing = 4
            stack.alignment = UIStackView.Alignment.leading
            return stack
        }()
        
        let trackImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = 10.0
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
    
        let darkLayer: UIView = {
            let view = UIView()
            view.layer.cornerRadius = 10.0
            view.layer.masksToBounds = true
            view.contentMode = .scaleAspectFill
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .TravDarkBlue()
            view.alpha = 0.35
            return view
        }()
        
        let lockImage: UIImageView = {
            let imageView = UIImageView()
            imageView.layer.cornerRadius = 10.0
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(imageLiteralResourceName: "Lock")
            return imageView
        }()

        //MARK: UPDATE
        var track: Track! {
            didSet {
                self.updateUI()
                self.setNeedsLayout()
            }
        }
        
        
        private func updateUI(){
            trackNameLabel.text = track.name
            trackNameLabel.font = UIFont.TravDemiMedium()
            trackNameLabel.textColor = .white
            locationLabel.text = track.location
            locationLabel.font = UIFont.TravDemiSmall()
            locationLabel.textColor = .white
            self.accessibilityHint = "Double tap to Play"
            
            trackImageView.image = UIImage(imageLiteralResourceName: "cell-placeholder")
            let imageURL = URL(string:track.image!)
            DispatchQueue.main.async(execute: {
                self.trackImageView.sd_setImage(with: imageURL, placeholderImage:#imageLiteral(resourceName: "cell-placeholder"), options: [.continueInBackground])
            })
            
            checkMonetized()
            checkFavorite()
            
        }
        
        func checkMonetized(){
            if track.isMonetized == true {
                if UserDefaults.standard.isPurchased() != true {
                    lockImage.alpha = 1.0
                } else {
                   lockImage.alpha = 0.0
                }
            } else {
                lockImage.alpha = 0.0
            }
        }
        
        func checkFavorite(){
            if API.checkIfEventExists(id: track.id!) != true {
                favoriteButton.setImage(UIImage(named: "favorite"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(named: "favorite-selected"), for: .normal)
            }
        }
    
}
