//
//  LoginViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 10/31/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    var loginView = LoginView()
    var resetView = ResetView()
    var registerView = RegisterView()
    
    var cancelButton: UIButton = {
        let sb = UIButton()
        let image = UIImage(named: "min-button") as UIImage?
        sb.setImage(image, for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        // dismiss keyboard on tap
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.view.addSubview(loginView)
        self.view.addSubview(resetView)
        self.view.addSubview(registerView)
        self.view.addSubview(cancelButton)
        
        cancelButton.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 44, heightConstant: 44)
        
        resetView.anchor(cancelButton.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        loginView.anchor(cancelButton.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        registerView.anchor(cancelButton.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        resetView.isHidden = true
        loginView.isHidden = false
        registerView.isHidden = true
        
        self.loginView.submitButton.addTarget(self, action: #selector(loginSubmitButtonPressed), for: .touchUpInside)
        self.loginView.resetButton.addTarget(self, action: #selector(loginResetButtonPressed), for: .touchUpInside)
        self.loginView.registerButton.addTarget(self, action: #selector(loginRegisterButtonPressed), for: .touchUpInside)
        self.registerView.submitButton.addTarget(self, action: #selector(registerSubmitButtonPressed), for: .touchUpInside)
        self.registerView.termsButton.addTarget(self, action: #selector(viewTermsOfService), for: .touchUpInside)
        self.registerView.privacyButton.addTarget(self, action: #selector(viewPrivacyPolicy), for: .touchUpInside)
        self.registerView.agreeButton.button.addTarget(self, action: #selector(agreeButtonPressed), for: .touchUpInside)
        self.registerView.loginButton.addTarget(self, action: #selector(registerLoginButtonPressed), for: .touchUpInside)
        self.resetView.submitButton.addTarget(self, action: #selector(resetSubmitButtonPressed), for: .touchUpInside)
        self.resetView.loginButton.addTarget(self, action: #selector(resetCancelButtonPressed), for: .touchUpInside)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: LOGIN
    @objc func loginSubmitButtonPressed(_ sender: Any) {
        self.loginView.validationLabel.text = " "
        self.loginView.validationLabel.isHidden = true
        if let email = self.loginView.emailField.text, let password = self.loginView.passwordField.text {
            if (self.loginView.emailField.text != "") && (self.loginView.passwordField.text != "") {
                Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                    if error != nil {
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            
                            self.loginView.validationLabel.isHidden = false
                            
                            switch errCode {
                            case .userNotFound:
                                self.loginView.validationLabel.text = "No user found with this email, please register."
                            case .invalidEmail:
                                self.loginView.validationLabel.text = "Please provide a valid email."
                            case .wrongPassword:
                                self.loginView.validationLabel.text = "Incorrect password."
                            default:
                                self.loginView.validationLabel.text = "Login Error: \(String(describing: error!.localizedDescription))."
                            }
                        }
                        
                    } else {
                        let defaults = UserDefaults.standard
                        defaults.set(true, forKey:"isLoggedIn")
                        defaults.synchronize()
                        NotificationCenter.default.post(name: .LoggedInNotification, object: nil)
                        Alerts.showSuccessBanner("Great, you are now logged in!")
                        AnalyticsService.logLoginEvent()
                    }
                }
            } else {
                self.loginView.validationLabel.isHidden = false
                self.loginView.validationLabel.text = "Please provide an email address and a password."
            }
        }
    }
    
    @objc func loginResetButtonPressed(_sender: Any){
        resetView.isHidden = false
        loginView.isHidden = true
        registerView.isHidden = true
    }
    
    @objc func loginRegisterButtonPressed(_sender: Any){
        resetView.isHidden = true
        loginView.isHidden = true
        registerView.isHidden = false
    }
    
    // MARK: RESET
    @objc func resetSubmitButtonPressed(_sender: Any){
        if let email = self.resetView.emailField.text {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if error != nil {
                    Alerts.showErrorBanner(error?.localizedDescription ?? "reason unknown, please contact us at info@thetravelear.com")
                } else {
                    Alerts.showSuccessBanner("Great, please check your email!")
                }
            }
        }
    }
    
    @objc func resetCancelButtonPressed(_sender: Any){
        resetView.isHidden = true
        loginView.isHidden = false
        registerView.isHidden = true
    }
    
    // MARK: Register
    @objc func registerSubmitButtonPressed() {
        
        self.registerView.validationLabel.text = " "
        self.registerView.validationLabel.isHidden = true
        let user = Auth.auth().currentUser
        
        if self.registerView.agreeButton.isOn == false {
            self.registerView.validationLabel.isHidden = false
            self.registerView.validationLabel.text = "Please review agree to our terms of service to continue, please email us with questions at info@thetravelear.com"
        } else {
            
            self.registerView.validationLabel.isHidden = true
            
            if let name = self.registerView.firstNameField.text, let email = self.registerView.emailField.text, let password = self.registerView.passwordField.text {
                
                if self.registerView.firstNameField.text != "" {
                    if self.registerView.emailField.text != "" {
                        if self.registerView.passwordField.text == self.registerView.confirmPasswordField.text {

                            let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                            user?.link(with: credential, completion: { (authResult, error) in
                                if error != nil {
                                    if let errCode = AuthErrorCode(rawValue: error!._code) {
                                        self.registerView.validationLabel.isHidden = false
                                        switch errCode {
                                        case .invalidEmail:
                                            self.registerView.validationLabel.text = "Email address is in an invalid format."
                                        case .emailAlreadyInUse:
                                            self.registerView.validationLabel.text = "Email address is already in use."
                                        default:
                                            self.registerView.validationLabel.text = "Create User Error: \(String(describing: error!.localizedDescription))."
                                        }
                                    }
                                } else {
                                    self.setRemoteData(name: name, email: email)
                                    AnalyticsService.logRegisterEvent()
                                    Auth.auth().currentUser?.sendEmailVerification { (error) in
                                        if error != nil {
                                            Alerts.showErrorBanner(error?.localizedDescription ?? "reason unknown, please contact us at info@thetravelear.com")
                                        } else {
                                            Alerts.showSuccessBanner("Great, please check your email!")
                                            NotificationCenter.default.post(name: NSNotification.Name(rawValue:"checkChangesAuth"), object: nil)
                                            let defaults = UserDefaults.standard
                                            defaults.setValue(true, forKey: "showLogin")
                                            try! Auth.auth().signOut()
                                            defaults.set(false, forKey: "isLoggedIn")
                                        }
                                    }
                                }
                            })
                            
                        } else {
                            self.registerView.validationLabel.isHidden = false
                            self.registerView.validationLabel.text = "Password and confirm password do not match."
                        }
                    } else {
                        self.registerView.validationLabel.isHidden = false
                        self.registerView.validationLabel.text = "Please provide an email address."
                    }
                } else {
                    self.registerView.validationLabel.isHidden = false
                    self.registerView.validationLabel.text = "Please provide a first name."
                }
            } else {
                print ("missing fields")
            }
        }
        
    }
    
    func setRemoteData(name:String, email:String){
        let user = Auth.auth().currentUser
        let uid = user!.uid
        let db = Firestore.firestore()
        let joinDate = Date()
        
        db.collection("users").document(uid).updateData([
            "email": email,
            "firstName": name,
            "id": uid,
            "joined" : joinDate,
            "subscription_active" : "active",
            ])
        
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(name, forKey: "firstName")
        defaults.set(joinDate, forKey: "joined")
        defaults.synchronize()
    }
    
    @objc func registerLoginButtonPressed(_sender: Any){
        resetView.isHidden = true
        loginView.isHidden = false
        registerView.isHidden = true
    }
    
    @objc func agreeButtonPressed(_sender: Any){
        let user = Auth.auth().currentUser
        let uid = user!.uid
        let db = Firestore.firestore()
        if self.registerView.agreeButton.isOn == false {
            db.collection("users").document(uid).updateData([ "agreedToTerms": false ])
        } else {
            db.collection("users").document(uid).updateData([ "agreedToTerms": true ])
        }
    }
    
    @objc func viewTermsOfService(_sender: Any){
        if let url = URL(string: AppConstants.termsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func viewPrivacyPolicy(_sender: Any){
        if let url = URL(string: AppConstants.privacyURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: MAIN
    @objc func dismissView(){
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}
