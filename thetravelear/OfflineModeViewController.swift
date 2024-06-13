//
//  OfflineModeViewController.swift
//  Travelear
//
//  Created by Nick Culpin on 1/8/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import UIKit

class OfflineModeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        backgroundColor = UIColor.black
    }

}
