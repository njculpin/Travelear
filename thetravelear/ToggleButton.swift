//
//  ToggleButton.swift
//  sleep
//
//  Created by Nick Culpin on 1/22/20.
//  Copyright © 2020 Travelear, Inc. All rights reserved.
//
import Foundation

class ToggleButton: UIView {
    
    var on: String?
    var off: String?
    var startOn: Bool?
    var isOn: Bool = false
        
    lazy var body: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var buttonImage: UIImageView = {
        let view = UIImageView()
        let image = UIImage(named: "Off")
        view.image = image
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggle), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    var leftConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    
    init(startOn: Bool) {
        super.init(frame: CGRect())
        self.startOn = startOn
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        roundCorners(corners: [.topLeft, .bottomLeft, .topRight, .bottomRight], radius: self.bounds.width/2)
    }
    
    func setupViews(){
        self.addSubview(body)
        self.addSubview(buttonImage)
        self.addSubview(button)
        
        leftConstraint = buttonImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
        leftConstraint?.isActive = true
        
        rightConstraint = buttonImage.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        rightConstraint?.isActive = false
        
        body.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        buttonImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        buttonImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        buttonImage.anchorCenterYToSuperview()
        
        button.fillSuperview()
        
        if startOn! { toggle() }
    }
    
    @objc func toggle(){
        isOn.toggle()
          if isOn == false {
            let image = UIImage(named: "Off")
            buttonImage.image = image
            rightConstraint?.isActive = false
            leftConstraint?.isActive = true
            animate()
          } else {
            let image = UIImage(named: "On")
            buttonImage.image = image
            rightConstraint?.isActive = true
            leftConstraint?.isActive = false
            animate()
          }
    }
    
    func animate(){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.curveLinear, animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
}
