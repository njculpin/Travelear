//
//  AccessibilityService.swift
//  Travelear
//
//  Created by Nicholas Culpin on 7/30/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation
import UIKit

class AccessibilityService {
    
    class func isVoiceOver() -> Bool {
        let voiceOverON: Bool = UIAccessibility.isVoiceOverRunning
        if voiceOverON != false {
            AnalyticsService.logVoiceOverSet(isSet: true)
            return true
        } else {
            AnalyticsService.logVoiceOverSet(isSet: false)
            return false
        }
    }
    
    
}
