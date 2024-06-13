//
//  UIColor+Travelear.swift
//  thetravelear
//
//  Created by Nicholas Culpin on 12/15/16.
//  Copyright © 2016 thetravelear. All rights reserved.
//

import Foundation

extension UIColor {
        
    class func TravMediumBlue() -> UIColor {
    return UIColor(red:0.11, green:0.16, blue:0.20, alpha:1.0)
    }
    
    class func TravDarkBlue() -> UIColor {
    return UIColor(red:0.05, green:0.07, blue:0.09, alpha:1.0)
    }
    
    class func TravDarkBlueTransparent() -> UIColor {
        return UIColor(red:0.05, green:0.07, blue:0.09, alpha:0.5)
    }
    
    class func TravWhite() -> UIColor {
        return UIColor(red:0.97, green:0.98, blue:0.99, alpha:1.0)
    }
    
    class func TravLightBlue() -> UIColor {
        return UIColor(red:0.08, green:0.69, blue:1.00, alpha:1.0)
    }
    
    class func TravRed() -> UIColor {
        return UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
    }
    
    class func PatreonCoral() -> UIColor {
        return UIColor(
            red:convertToZeroToOne(number: 249),
            green:convertToZeroToOne(number: 104),
            blue:convertToZeroToOne(number: 84),
            alpha:1.0)
    }
    
    class func convertToZeroToOne(number:CGFloat) -> CGFloat {
        return number / 255
    }

}
