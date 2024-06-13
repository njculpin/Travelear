//
//  BasicTableViewCell.swift
//  Travelear
//
//  Created by Nick Culpin on 1/2/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import UIKit

protocol BasicCellDelegate {
  func downloadButtonPressed(_ cell: BasicTableViewCell)
}

class BasicTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: DRAW
    func setupViews() {
        addSubview(stackView)
        stackView.addArrangedSubview(lockImage)
        stackView.addArrangedSubview(trackNameLabel)
        stackView.addArrangedSubview(locationLabel)
        stackView.addArrangedSubview(progressBar)
        stackView.anchor(topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        progressBar.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        progressBar.tintColor = UIColor.TravRed()
        
        lockImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        lockImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        if isDownloaded == true {
            progress = 1.0
        }
    }

    var delegate: BasicCellDelegate?
    var isDownloaded = Bool()
    lazy var trackNameLabel = TravelearLabel()
    lazy var locationLabel = TravelearLabel()
    lazy var progressBar: UIProgressView = {
        let pb = UIProgressView()
        return pb
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

    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.distribution = UIStackView.Distribution.equalSpacing
        stack.spacing = 4
        stack.alignment = UIStackView.Alignment.leading
        return stack
    }()

    //MARK: UPDATE
    var track: Track! {
        didSet {
            self.updateUI()
            self.setNeedsLayout()
        }
    }
    
    var progress: Float? {
        didSet{
            self.updateUI()
            self.setNeedsLayout()
        }
    }

    private func updateUI(){
        trackNameLabel.text = track.name
        trackNameLabel.font = UIFont.TravDemiMedium()
        locationLabel.text = track.location
        locationLabel.font = UIFont.TravRegularSmall()
        progressBar.progress = progress ?? 0.0
        self.accessibilityHint = "Double tap to Play"
        checkMonetized()
    }
    
    @objc func downloadButtonPressed(){
        delegate?.downloadButtonPressed(self)
    }
    
    func updateDisplay(progress: Float, totalSize : String) {
      progressBar.progress = progress
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






