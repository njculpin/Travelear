//
//  CheckBox.swift
//  sleep
//
//  Created by Nick Culpin on 1/22/20.
//  Copyright © 2020 Travelear, Inc. All rights reserved.
//
import Foundation

class CheckBox: UIView {
    
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
        let image = UIImage(named: "CheckOff")
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
        
        body.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

        buttonImage.heightAnchor.constraint(equalToConstant: 22).isActive = true
        buttonImage.widthAnchor.constraint(equalToConstant: 22).isActive = true
        buttonImage.anchorCenterSuperview()
        
        button.fillSuperview()
        
        if startOn! { toggle() }
    }
    
    @objc func toggle(){
        isOn.toggle()
          if isOn == false {
            let image = UIImage(named: "CheckOff")
            buttonImage.image = image
          } else {
            let image = UIImage(named: "CheckOn")
            buttonImage.image = image
          }
    }
    
}
