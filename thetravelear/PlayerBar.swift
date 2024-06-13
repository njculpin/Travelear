//
//  PlayerBar.swift
//  Travelear
//
//  Created by Nicholas Culpin on 7/17/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class PlayerBar: UIView {
    
    let trackImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var timeSlider: UISlider = {
        let view = UISlider()
        view.maximumTrackTintColor = .TravRed()
        view.minimumTrackTintColor = .TravDarkBlue()
        view.backgroundColor = .white
        view.thumbTintColor = .clear
        return view
    }()
    
    lazy var currentTimeLabel = TravelearLabel()
    lazy var trackNameLabel = TravelearLabel()
    lazy var trackLocationLabel = TravelearLabel()
    
    lazy var pausePlayButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    lazy var verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.fillProportionally
        stack.spacing = 2
        stack.alignment = UIStackView.Alignment.leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = UIColor.white
        return stack
    }()
    
    lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()
    
    init() {
        super.init(frame: CGRect())
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(timeSlider)
        addSubview(containerView)
        
        containerView.addSubview(trackImage)
        containerView.addSubview(verticalStackView)
        containerView.addSubview(pausePlayButton)
        
        verticalStackView.addArrangedSubview(trackNameLabel)
        verticalStackView.addArrangedSubview(trackLocationLabel)
        
        timeSlider.anchor(topAnchor, left: leftAnchor, bottom: containerView.topAnchor, right: rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 6, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        containerView.anchor(timeSlider.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 44)
        
        trackImage.anchor(containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: verticalStackView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 44, heightConstant: 44)
        verticalStackView.anchor(containerView.topAnchor, left: trackImage.rightAnchor, bottom: containerView.bottomAnchor, right: pausePlayButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
        pausePlayButton.anchor(containerView.topAnchor, left: nil, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
    }
    
    var track: Track! {
        didSet {
            self.updateUI()
            self.setNeedsLayout()
        }
    }
    
    private func updateUI(){
        
        trackNameLabel.text = track.name
        trackImage.isAccessibilityElement = true
        trackImage.accessibilityValue = "Now Playing \(String(describing: track.name!))"
        pausePlayButton.isAccessibilityElement = true
        pausePlayButton.accessibilityLabel = "Play \(track.name!)"
        let imageURL = URL(string:track.image!)
        DispatchQueue.main.async(execute: {
            self.trackImage.sd_setImage(with: imageURL, placeholderImage:#imageLiteral(resourceName: "lockscreen-default"), options: [.continueInBackground])
        })
        
        self.accessibilityHint = "Double tap to Play"

    }
    
}
