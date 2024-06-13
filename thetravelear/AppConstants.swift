//
//  AppConstants.swift
//  Travelear
//
//  Created by Nick Culpin on 2/1/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation

class AppConstants {
    
    static let mandatoryBuild = ""
    static let mandatoryVersion = ""
    static let appStoreID = ""
    static let bundleID = ""
    static let publisherID = ""
    static let startTrackID = ""
    static let termsURL = ""
    static let privacyURL = ""
    static let castRecieverAppID = ""
    static let fieldWidth = CGFloat(UIScreen.main.bounds.width-32)
    static let fieldHeight = CGFloat(66)
    static let cellHeight = 145
    static let cellWidth = UIScreen.main.bounds.width
    
    
    class func isTestFlight() -> Bool{
        if isSimulator() {
            return false
        } else {
            if isAppStoreReceiptSandbox() && !hasEmbeddedMobileProvision() {
                return true
            } else {
                return false
            }
        }
    }
    
    class func isAppStore() -> Bool {
        if isSimulator(){
            return false
        } else {
            if isAppStoreReceiptSandbox() || hasEmbeddedMobileProvision() {
                return false
            } else {
                return true
            }
        }
    }
    
    class func hasEmbeddedMobileProvision() -> Bool{
        if let _ = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") {
            return true
        }
        return false
    }
    
    class func isAppStoreReceiptSandbox() -> Bool {
        if isSimulator() {
            return false
        } else {
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL {
                let appStoreReceiptLastComponent = appStoreReceiptURL.lastPathComponent
                if appStoreReceiptLastComponent == "sandboxReceipt" {
                    return true
                }
                return false
            }
        }
        return false
    }
    
    class func isSimulator() -> Bool {
        #if arch(i386) || arch(x86_64)
            return true
            #else
            return false
        #endif
    }
    
}
