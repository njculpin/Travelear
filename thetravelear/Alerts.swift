//
//  Alerts.swift
//  Travelear
//
//  Created by Nick Culpin on 12/20/19.
//  Copyright © 2019 thetravelear. All rights reserved.
//

import Foundation
import SwiftMessages

class Alerts {
        
    static func showHeadPhonesWarning() {
        if UserDefaults.standard.hasShownHeadphoneDialog() == false {
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 250)
            messageView.configureContent(title: "Hey There!", body: "Put on your headphones for a better experience!", iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "Ok!") { _ in
                SwiftMessages.hide()
            }
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
            UserDefaults.standard.set(true, forKey: "hasShownHeadphoneDialog")
        }
    }
    
    static func showErrorBanner(_ text: String) {
        let banner = MessageView.viewFromNib(layout: .cardView)
        banner.configureTheme(.error)
        banner.button?.isHidden = true
        banner.backgroundView.backgroundColor = UIColor.TravRed()
        banner.configureContent(title: "Oops!", body: text)
        SwiftMessages.show(view: banner)
    }
    
    static func showSuccessBanner(_ text: String) {
        let banner = MessageView.viewFromNib(layout: .cardView)
        banner.configureTheme(.success)
        banner.button?.isHidden = true
        banner.backgroundView.backgroundColor = UIColor.TravLightBlue()
        banner.configureContent(title: "Woo!", body: text)
        SwiftMessages.show(view: banner)
    }
    
    static func showNoInternet() {
        let banner = MessageView.viewFromNib(layout: .statusLine)
        banner.configureTheme(.error)
        banner.button?.isHidden = true
        banner.backgroundView.backgroundColor = UIColor.TravLightBlue()
        banner.configureContent(title: "Offline", body: "No Internet available!")
        SwiftMessages.show(view: banner)
    }
    
}
