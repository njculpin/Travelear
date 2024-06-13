//
//  EmailUs.swift
//  thetravelear
//
//  Created by Nicholas Culpin on 2/6/17.
//  Copyright © 2017 thetravelear. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class Email: NSObject, MFMailComposeViewControllerDelegate {
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["info@thetravelear.com"])
        mailComposerVC.setSubject("Travelear App Feedback")
        mailComposerVC.setMessageBody("Hello, My device information is \(versionText())", isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func versionText()->String{
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        let settings = "Version = \(version) - Build =\(build)"
        return settings
    }
}

