//
//  PaddedLabel.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/10/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation

class TravelearLabel: UILabel {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeLabel()
    }
    
    func initializeLabel() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfLines = 0
        self.lineBreakMode = .byWordWrapping
        
    }
    
}

class TravelearLabelPadded: TravelearLabel {
    
    var padding = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    public override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}


