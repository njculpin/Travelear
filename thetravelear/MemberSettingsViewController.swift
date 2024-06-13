//
//  DidPurchaseViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 12/2/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class MemberSettingsViewController: UIViewController {
    
    lazy var popOverTitleLabel = TravelearLabel()
    lazy var email = TravelearLabel()
    lazy var firstName = TravelearLabel()
    lazy var lastName = TravelearLabel()
    lazy var joined = TravelearLabel()
    lazy var subscription_active = TravelearLabel()
    lazy var subscription_period_start = TravelearLabel()
    lazy var subscription_period_end = TravelearLabel()
    lazy var subscription_nickname = TravelearLabel()
    lazy var notes = TravelearLabel()
    
    var cancelButton: UIButton = {
        let sb = UIButton()
        let image = UIImage(named: "min-button") as UIImage?
        sb.setImage(image, for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return sb
    }()
    
    var goToSettingsButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Manage Subscription", for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.setTitleColor(.white, for: .normal)
        sb.backgroundColor = UIColor.TravRed()
        sb.heightAnchor.constraint(equalToConstant: 44).isActive = true
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.addTarget(self, action: #selector(goToSettingsPressed), for: .touchUpInside)
        return sb
    }()
    
    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.spacing = 0
        return stack
    }()
    
    var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.spacing = 4
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        view.addSubview(stackView)
        view.addSubview(contentStackView
        )
        stackView.addArrangedSubview(popOverTitleLabel)
        stackView.addArrangedSubview(cancelButton)
        stackView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        contentStackView.addArrangedSubview(email)
        contentStackView.addArrangedSubview(firstName)
        contentStackView.addArrangedSubview(lastName)
        contentStackView.addArrangedSubview(joined)
        contentStackView.addArrangedSubview(subscription_active)
        contentStackView.addArrangedSubview(subscription_period_start)
        contentStackView.addArrangedSubview(subscription_period_end)
        contentStackView.addArrangedSubview(subscription_nickname)
        contentStackView.addArrangedSubview(notes)
        contentStackView.addArrangedSubview(goToSettingsButton)
        
        contentStackView.anchor(self.stackView.bottomAnchor, left:self.view.safeAreaLayoutGuide.leftAnchor, bottom:nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 22, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        
        popOverTitleLabel.widthAnchor.constraint(equalToConstant: self.view.bounds.width - 44 ).isActive = true
        popOverTitleLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        popOverTitleLabel.text = "My Membership"
        popOverTitleLabel.font = UIFont.TravTitle()
        
        getUserData()
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func getUserData(){
        API.getUser{ (model) -> () in
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_US")
            
            if model.firstName != " " {
                self.firstName.text = "Hey, \(String(describing: model.firstName!))!"
            } else {
                self.firstName.text = "Hey, Travelear!"
            }
            
            self.joined.text = "Member since \(dateFormatter.string(from:model.joined ?? Date()))"
            self.subscription_active.text = "Status: \(String(describing: model.subscription_active!))"
            self.subscription_period_start.text = "Start Date: \(String(describing: model.subscription_period_start!.toString()))"
            self.subscription_period_end.text = "Will renew on \(String(describing: model.subscription_period_end!.toString()))"
            self.subscription_nickname.text = "Membership Level: \(String(describing: model.subscription_nickname!))"
            switch model.vender {
                case "apple-world":
                    self.goToSettingsButton.isHidden = false
                case "apple-sleep":
                    self.goToSettingsButton.isHidden = false
                case "stripe-world":
                    self.goToSettingsButton.isHidden = true
                    self.notes.text = "To change your subscription please visit Settings at www.thetravelear.com"
                default:
                    self.goToSettingsButton.isHidden = false
                    self.notes.text = "To change your subscription please visit your account settings in the platform you purchased it. If you are having trouble, please contact us at info@thetravelear.com"
            }
        }
    }
    
    @objc func goToSettingsPressed(){
        let alertController = UIAlertController (title: "You are about to leave Travelear", message: "Go to Settings?", preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
