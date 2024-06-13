//
//  ListCollectionViewCell.swift
//  Travelear
//
//  Created by Nicholas Culpin on 6/14/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//
import UIKit

class ListCollectionViewCell: BaseCollectionViewCell {
    
    //MARK: DRAW
    override func setupViews() {
        
        addSubview(trackAuthorButton)
        addSubview(trackAuthorLabel)
        addSubview(moreButton)
        addSubview(trackImageView)
        addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(lockImage)
        contentStackView.addArrangedSubview(trackNameLabel)
        contentStackView.addArrangedSubview(trackAuthorLocationLabel)
        
        trackAuthorButton.anchor(topAnchor, left: leftAnchor, bottom: nil, right: trackAuthorLabel.leftAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
        
        trackAuthorLabel.anchor(nil, left: trackAuthorButton.rightAnchor, bottom: trackImageView.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 44)
        
        moreButton.anchor(topAnchor, left: nil, bottom: trackImageView.topAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 44, heightConstant: 44)
        
        trackImageView.anchor(moreButton.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        contentStackView.anchor(nil, left:leftAnchor, bottom:bottomAnchor, right:rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 16, rightConstant: 22, widthConstant: 0, heightConstant: 0)
        
        lockImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lockImage.widthAnchor.constraint(equalToConstant: 22).isActive = true

    }
    
    
    
    let trackImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var trackAuthorLabel = TravelearLabel()
    
    lazy var trackAuthorButton: UIView = {
        let pb = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        return pb
    }()
    
    lazy var authorButton: UIButton = {
        let buttonView = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        buttonView.setImage(UIImage(named: "profile-pressed"), for: .normal)
        buttonView.contentMode = UIView.ContentMode.scaleAspectFit
        buttonView.layer.cornerRadius = 17.5
        buttonView.layer.masksToBounds = true
        buttonView.isAccessibilityElement = true
        trackAuthorButton.addSubview(buttonView)
        return buttonView
    }()
    
    lazy var trackNameLabel =  TravelearLabelPadded()
    lazy var trackAuthorLocationLabel =  TravelearLabelPadded()
    
    lazy var titleBar: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    lazy var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.fillProportionally
        stack.spacing = 4
        stack.alignment = UIStackView.Alignment.leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = UIColor.white
        return stack
    }()
    
    lazy var moreButton: UIButton = {
        let sb = UIButton()
        sb.setImage(UIImage(named: "More-Dark"), for: .normal)
        sb.isAccessibilityElement = true
        sb.accessibilityLabel = "More Context"
        return sb
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
        
        self.trackAuthorLabel.text = "\(track.creatorName!)"
        self.trackAuthorButton.accessibilityLabel = "More from \(track.creatorName!)"
        let authorImageURL = URL(string:track.creatorImage!)
        DispatchQueue.main.async(execute: {
            self.authorButton.sd_setImage(with: authorImageURL, for: .normal, completed: nil)
        })
        trackAuthorLocationLabel.text = track.location
        trackAuthorLocationLabel.font = UIFont.TravRegularSmall()
        trackAuthorLocationLabel.textColor = .black
        trackAuthorLocationLabel.backgroundColor = .white
        
        trackNameLabel.isAccessibilityElement = false
        trackAuthorLocationLabel.isAccessibilityElement = false
        trackImageView.isAccessibilityElement = false
        
        trackNameLabel.text = track.name
        trackNameLabel.font = UIFont.TravDemiMedium()
        trackNameLabel.textColor = .black
        trackNameLabel.backgroundColor = .white
        trackAuthorLabel.font = UIFont.TravDemiMedium()
        trackImageView.image = UIImage(imageLiteralResourceName: "cell-placeholder")
        let imageURL = URL(string:track.image!)
        DispatchQueue.main.async(execute: {
            self.trackImageView.sd_setImage(with: imageURL, placeholderImage:#imageLiteral(resourceName: "cell-placeholder"), options: [.continueInBackground])
        })
        self.accessibilityHint = "Double tap to Play"
        
        checkMonetized()
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
    
}
