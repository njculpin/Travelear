//
//  UpgradeBanner.swift
//  Travelear
//
//  Created by Nick Culpin on 2/14/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation
import UIKit

class UpgradeBanner: UIView {
    
    var button: UIButton = {
        let btn = UIButton()
        return btn
    }()

    var title = String()
    
    init(title: String) {
        super.init(frame: CGRect())
        self.title = title
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        addSubview(button)
        button.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
        button.setTitle(self.title, for: .normal)
        button.backgroundColor = .TravRed()
        button.titleLabel?.font = UIFont.TravDemiSmall()
    }
    
}
