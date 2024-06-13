//
//  ProfileViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 6/23/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import MessageUI

class ProfileViewController: TravelearViewController, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {
    
    lazy var profileTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(ButtonImageCell.self, forCellReuseIdentifier: "ButtonImageCell")
        tv.register(ButtonTextCell.self, forCellReuseIdentifier: "ButtonTextCell")
        tv.register(TextCell.self, forCellReuseIdentifier: "VersionCell")
        tv.register(TextCell.self, forCellReuseIdentifier: "TitleCell")
        tv.register(TextCell.self, forCellReuseIdentifier: "SubscriptionCell")
        return tv
    }()

    lazy var popOverTitleLabel = TravelearLabel()

    var cancelButton: UIButton = {
        let sb = UIButton()
        let image = UIImage(named: "min-button") as UIImage?
        sb.setImage(image, for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return sb
    }()

    var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.spacing = 0
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(stackView)
        view.addSubview(profileTableView)
        stackView.addArrangedSubview(popOverTitleLabel)
        stackView.addArrangedSubview(cancelButton)
        stackView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
        popOverTitleLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        profileTableView.anchor(self.stackView.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        profileTableView.tableFooterView = UIView(frame: .zero)
        profileTableView.alwaysBounceVertical = false
        profileTableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkProfileChanges),
                                               name: .LoggedInNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileViewController.handlePurhaseNotification(_:)),
                                               name: .PurchaseNotification,
                                               object: nil)
        
        popOverTitleLabel.font = UIFont.TravTitle()
        popOverTitleLabel.text = "Profile"
        
    }

    override func viewDidAppear(_ animated: Bool) {
        checkProfileChanges()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profileTableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 200, right: 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ButtonTextCell", for: indexPath) as? ButtonTextCell {
                    cell.buttonTextLabel.text = "Shop"
                    cell.selectionStyle = .none
                    return cell
                }
            case 1:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ButtonTextCell", for: indexPath) as? ButtonTextCell {
                    cell.buttonTextLabel.text = "Contact Us"
                    cell.selectionStyle = .none
                    return cell
                }
            case 2:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ButtonTextCell", for: indexPath) as? ButtonTextCell {
                    cell.buttonTextLabel.text = "Write a review"
                    cell.selectionStyle = .none
                    return cell
                }
            case 3:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ButtonTextCell", for: indexPath) as? ButtonTextCell {
                    cell.selectionStyle = .none
                    return cell
                }
            case 4:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "VersionCell", for: indexPath) as? TextCell {
                    let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
                    let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
                    cell.buttonTextLabel.text = "Travelear Version = \(version), Build = \(build)"
                    cell.buttonTextLabel.font = UIFont.TravRegularSmall()
                    cell.selectionStyle = .none
                    return cell
                }
            case 5:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as? TextCell {
                    cell.buttonTextLabel.font = UIFont.TravRegularSmall()
                    cell.selectionStyle = .none
                    return cell
                }
            case 6:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ButtonTextCell", for: indexPath) as? ButtonTextCell {
                    cell.buttonTextLabel.font = UIFont.TravRegularSmall()
                    cell.buttonTextLabel.text = "Terms of Service"
                    cell.selectionStyle = .none
                    return cell
                }
            case 7:
                if let cell = profileTableView.dequeueReusableCell(withIdentifier: "ButtonTextCell", for: indexPath) as? ButtonTextCell {
                    cell.buttonTextLabel.font = UIFont.TravRegularSmall()
                    cell.buttonTextLabel.text = "Privacy Policy"
                    cell.selectionStyle = .none
                    return cell
                }
            default:break
            }
        default : break
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                self.shop()
            case 1:
                self.contactUs()
            case 2:
                self.reviewUs()
            case 3:
                self.loginOut()
            case 6:
                self.viewTermsOfService()
            case 7:
                self.viewPrivacyPolicy()
            default:break
            }
        default : break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }

    @objc func loginOut(){
        let defaults = UserDefaults.standard
        let isLoggedIn = defaults.isLoggedIn()
        if isLoggedIn == true {
            logOut()
        } else {
            showLogIn()
        }
    }
    
    func showLogIn(){
        let controller = LoginViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }

    func logOut(){
        try! Auth.auth().signOut()
        let defaults = UserDefaults.standard
        defaults.resetDefaults()
        defaults.set(false, forKey:"isLoggedIn")
        defaults.synchronize()
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error != nil {
                print ("log out error = \(String(describing: error))")
            } else {
                self.checkProfileChanges()
            }
        })
    }
    
    @objc func handlePurhaseNotification(_ notification: Notification){
        checkProfileChanges()
        profileTableView.reloadData()
    }

    @objc func checkProfileChanges(){
        let defaults = UserDefaults.standard
        let subscriptionIndexPath = IndexPath(row: 5, section: 0)
        let subscriptionCell = self.profileTableView.cellForRow(at: subscriptionIndexPath) as! TextCell
        let logInIndexPath = IndexPath(row: 3, section: 0)
        let logInCell = self.profileTableView.cellForRow(at: logInIndexPath) as! ButtonTextCell
        let shopIndexPath = IndexPath(row:0, section: 0)
        let shopCell = self.profileTableView.cellForRow(at: shopIndexPath) as! ButtonTextCell
        
        API.getUser{ (model) -> () in
            guard let name = model.firstName else { return }
            guard let subscription_active = model.subscription_active else { return }
            guard let end = model.subscription_period_end?.toString() else { return }
            guard let level = model.subscription_nickname else { return }
            
            if defaults.isLoggedIn() != true {
                self.popOverTitleLabel.text = "Hey, traveler"
                logInCell.buttonTextLabel.text = "Login"
                subscriptionCell.buttonTextLabel.text = "You are not subscribed"
            } else {
                self.popOverTitleLabel.text = "Hey, \(name)!"
                logInCell.buttonTextLabel.text = "Logout"

            }
    
            if subscription_active == "active" {
               subscriptionCell.buttonTextLabel.text = "You are subscribed for \(level) until \(end)"
                shopCell.buttonTextLabel.text = "My Membership"
            } else {
                shopCell.buttonTextLabel.text = "Shop"
                subscriptionCell.buttonTextLabel.text = "You are not subscribed"
            }
        }
        

    }

    func contactUs(){
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["xxx@thetravelear.com"])
            mail.setSubject("Travelear App Contact Us")
            mail.setMessageBody("Hello, My device information is \(versionText())", isHTML: false)
            present(mail, animated: true)
            let alertController = UIAlertController(title: "Yay!", message: "Talk to you soon!", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)

        } else {
            let alertController = UIAlertController(title: "Oops!", message: "Failed to send message please try again later", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

    func versionText()->String{
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")!
        let settings = "Version = \(version) - Build =\(build)"
        return settings
    }

    func reviewUs(){
        if let url = URL(string: "itms-apps://itunes.apple.com/app/XXXX") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
    
    func viewPrivacyPolicy(){
        if let url = URL(string: "https://www.thetravelear.com/privacy") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
    
    func viewTermsOfService(){
        if let url = URL(string: "https://www.thetravelear.com/terms") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                          completionHandler: {
                                            (success) in
                                            print("Open \(url): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
                print("Open \(url): \(success)")
            }
        }
    }
    
    func shop(){
        let defaults = UserDefaults.standard
        if defaults.isPurchased() == true {
            self.showMember()
        } else {
            self.showShop()
        }
    }
    
    func showMember(){
        let controller = MemberSettingsViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }
    
    func showShop(){
        let controller = PurchasesViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
