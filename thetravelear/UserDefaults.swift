//
//  UserDefaults.swift
//  Travelear
//
//  Created by Nicholas Culpin on 8/26/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation
import Firebase


extension UserDefaults {
    
    func isLoggedIn() -> Bool {
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.bool(forKey: "isLoggedIn")
        if isLoggedIn {
            return true
        }
        return false
    }
    
    func isPurchased() -> Bool {
        let defaults = UserDefaults.standard
        let isPurchased = defaults.bool(forKey: "isPurchased")
        if isPurchased {
            return true
        }
        return false
    }
    
    func isDownloaded() -> Bool {
        let defaults = UserDefaults.standard
        let isDownloaded = defaults.bool(forKey: "isDownloaded")
        if isDownloaded {
            return true
        }
        return false
    }
    
    func isConnected() -> Bool {
        let defaults = UserDefaults.standard
        let isConnected = defaults.bool(forKey: "isConnected")
        if isConnected {
            return true
        }
        return false
    }
    
    func hasShownHeadphoneDialog() -> Bool {
        let defaults = UserDefaults.standard
        let isConnected = defaults.bool(forKey: "hasShownHeadphoneDialog")
        if isConnected {
            return true
        }
        return false
    }

    
    func showLogin() -> Bool {
        let defaults = UserDefaults.standard
        let showLogin = defaults.bool(forKey: "showLogin")
        if showLogin {
            return true
        }
        return false
    }
    
    func isUsingVoiceOver() -> String {
        let defaults = UserDefaults.standard
        let isUsingVoiceOver = defaults.string(forKey: "isUsingVoiceOver") ?? "no"
        return isUsingVoiceOver
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
