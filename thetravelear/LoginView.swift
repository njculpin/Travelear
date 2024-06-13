//
//  LoginView.swift
//  Travelear
//
//  Created by Nick Culpin on 2/19/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation
import UIKit

class LoginView: UIView, UIScrollViewDelegate, UITextFieldDelegate {
    
    var scrollView: UIScrollView!
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel = TravelearLabel()
    
    lazy var emailField: UITextField = {
         let tf = UITextField()
         tf.placeholder = "Email"
         tf.isSecureTextEntry = false
         tf.autocorrectionType = .no
         tf.borderStyle = .none
         tf.backgroundColor = .white
         tf.translatesAutoresizingMaskIntoConstraints = false
         tf.font = UIFont.TravRegular()
         return tf
     }()
     
     lazy var passwordField: UITextField = {
         let tf = UITextField()
         tf.placeholder = "Password"
         tf.isSecureTextEntry = true
         tf.autocorrectionType = .no
         tf.borderStyle = .none
         tf.backgroundColor = .white
         tf.translatesAutoresizingMaskIntoConstraints = false
         tf.font = UIFont.TravRegular()
         return tf
     }()
     
     lazy var validationLabel = TravelearLabel()
     
     lazy var submitButton: UIButton = {
         let sb = UIButton(frame: CGRect(x: 0, y: 0, width: 66, height: 66))
         sb.setImage(UIImage(named: "submit"), for: .normal)
         sb.backgroundColor = UIColor.TravRed()
         sb.layer.cornerRadius = sb.bounds.width/2
         sb.layer.masksToBounds = true
         sb.translatesAutoresizingMaskIntoConstraints = false
         return sb
     }()
     
     lazy var resetButton: UIButton = {
         let sb = UIButton()
         sb.setTitle("Forgot your password? Reset it now!", for: .normal)
         sb.titleLabel?.textAlignment = .center
         sb.setTitleColor(UIColor.black, for: .normal)
         sb.titleLabel?.font = UIFont.TravRegularSmall()
         sb.backgroundColor = .white
         sb.translatesAutoresizingMaskIntoConstraints = false
         return sb
     }()
    
    lazy var registerButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Need an Account? Register", for: .normal)
        sb.titleLabel?.textAlignment = .center
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.titleLabel?.font = UIFont.TravRegularSmall()
        sb.backgroundColor = .white
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
     
     lazy var stackView: UIStackView = {
         let stack = UIStackView()
         stack.axis = NSLayoutConstraint.Axis.vertical
         stack.distribution = UIStackView.Distribution.equalSpacing
         stack.spacing = 16.0
         stack.alignment = UIStackView.Alignment.leading
         stack.translatesAutoresizingMaskIntoConstraints = false
         return stack
     }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        self.validationLabel.isHidden = true
        validationLabel.font = UIFont.TravRegular()
        validationLabel.textColor = UIColor.TravRed()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        contentView.addSubview(submitButton)
        contentView.addSubview(resetButton)
        contentView.addSubview(registerButton)

        self.stackView.addArrangedSubview(titleLabel)
        self.stackView.addArrangedSubview(validationLabel)
        self.stackView.addArrangedSubview(emailField)
        self.stackView.addArrangedSubview(passwordField)

        emailField.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        emailField.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)

        passwordField.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        passwordField.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
        
        
        scrollView.fillSuperview()
        contentView.fillSuperview()
        stackView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: submitButton.topAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 16, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        scrollView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 66, right: 0)
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -44).isActive = true
        submitButton.anchor(stackView.bottomAnchor, left: nil, bottom: resetButton.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 66, heightConstant: 66)
        resetButton.anchor(submitButton.bottomAnchor, left: contentView.leftAnchor, bottom: registerButton.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 66)
        registerButton.anchor(resetButton.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 66)

        titleLabel.text = "Login"
        titleLabel.font = UIFont.TravSubTitle()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            self.endEditing(true)
            emailField.becomeFirstResponder()
        default:
            self.endEditing(true)
            emailField.resignFirstResponder()
        }
        return true
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        let margin: CGFloat = 22
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = self.convert(keyboardScreenEndFrame, from: self.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 66, left: margin, bottom: (keyboardViewEndFrame.height + 66) - self.safeAreaInsets.bottom, right: margin)
        }
        scrollView.scrollIndicatorInsets = scrollView.contentInset
    }
    
}
