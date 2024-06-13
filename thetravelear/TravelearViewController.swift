//
//  TravelearViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/7/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import Firebase

class TravelearViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    lazy var profileButton: UIView = {
        let pb = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        let buttonView = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        buttonView.setImage(UIImage(named: "profile-pressed"), for: .normal)
        buttonView.backgroundColor = UIColor.white
        buttonView.contentMode = UIView.ContentMode.scaleAspectFit
        buttonView.layer.cornerRadius = 17.5
        buttonView.layer.masksToBounds = true
        buttonView.addTarget(self, action: #selector(showProfilePopover), for: .touchUpInside)
        pb.addSubview(buttonView)
        buttonView.accessibilityLabel = "My Profile"
        return pb
    }()
    
    lazy var titleLabel = TravelearLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func showProfilePopover(){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:"showProfile"), object: nil)
    }
    

}
