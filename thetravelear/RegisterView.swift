//
//  RegisterView.swift
//  Travelear
//
//  Created by Nick Culpin on 2/19/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import Foundation
import UIKit

class RegisterView: UIView, UIScrollViewDelegate, UITextFieldDelegate {
    
    var scrollView: UIScrollView!
    
    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var isPasswordValid = true
    
    lazy var whyLabel = TravelearLabel()
    
    lazy var firstNameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "First Name"
        tf.isSecureTextEntry = false
        tf.autocorrectionType = .no
        tf.borderStyle = .none
        tf.backgroundColor = .white
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.font = UIFont.TravRegular()
        return tf
    }()
    
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
        tf.addTarget(self, action: #selector(RegisterView.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        return tf
    }()
    
    lazy var confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Confirm Password"
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
    
    lazy var loginButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Already registered? Login", for: .normal)
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.titleLabel?.font = UIFont.TravRegularSmall()
        sb.backgroundColor = .white
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var termsButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Terms of service", for: .normal)
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.titleLabel?.font = UIFont.TravRegularSmall()
        sb.backgroundColor = .white
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var privacyButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Privacy policy", for: .normal)
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.titleLabel?.font = UIFont.TravRegularSmall()
        sb.backgroundColor = .white
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var agreeButton: CheckBox = {
        let sb = CheckBox(startOn: false)
        sb.backgroundColor = .lightGray
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    lazy var agreeLabel = TravelearLabel()
    
    lazy var termsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.distribution = UIStackView.Distribution.fillEqually
        stack.spacing = 4.0
        stack.alignment = UIStackView.Alignment.leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var agreeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.distribution = UIStackView.Distribution.fillProportionally
        stack.spacing = 4.0
        stack.alignment = UIStackView.Alignment.leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
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
        backgroundColor = .white
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        firstNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        contentView.addSubview(submitButton)
        contentView.addSubview(loginButton)
        
        stackView.addArrangedSubview(whyLabel)
        stackView.addArrangedSubview(validationLabel)
        stackView.addArrangedSubview(firstNameField)
        stackView.addArrangedSubview(emailField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(confirmPasswordField)
        stackView.addArrangedSubview(termsStack)
        stackView.addArrangedSubview(agreeStack)
        
        termsStack.addArrangedSubview(termsButton)
        termsStack.addArrangedSubview(privacyButton)
        
        agreeStack.addArrangedSubview(agreeButton)
        agreeStack.addArrangedSubview(agreeLabel)
        
        termsStack.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        termsStack.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        
        agreeStack.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        agreeStack.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        agreeButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        agreeButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        submitButton.widthAnchor.constraint(equalToConstant: 66).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 66).isActive = true
        
        firstNameField.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        firstNameField.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        firstNameField.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
        
        emailField.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        emailField.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        emailField.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
        
        passwordField.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        passwordField.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        passwordField.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
        
        confirmPasswordField.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        confirmPasswordField.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        confirmPasswordField.addLine(position: .LINE_POSITION_BOTTOM, color: .darkGray, width: 0.5)
        
        loginButton.widthAnchor.constraint(equalToConstant: AppConstants.fieldWidth).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: AppConstants.fieldHeight).isActive = true
        
        scrollView.fillSuperview()
        contentView.fillSuperview()
        stackView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: submitButton.topAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 16, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        scrollView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 66, right: 0)
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -44).isActive = true
        agreeStack.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        agreeStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -44).isActive = true
        submitButton.anchor(stackView.bottomAnchor, left: nil, bottom: loginButton.topAnchor, right: contentView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 66, heightConstant: 66)
        loginButton.anchor(submitButton.bottomAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: 66)

        
        whyLabel.text = "Register to save your content across all devices and Travelear products"
        whyLabel.font = UIFont.TravSubTitle()
        
        agreeLabel.text = "By checking this box you agree to the terms of service"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case firstNameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            confirmPasswordField.becomeFirstResponder()
        case confirmPasswordField:
            self.endEditing(true)
        default:
            self.endEditing(true)
            firstNameField.resignFirstResponder()
        }
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let attrStr = NSMutableAttributedString (
            string: "Password must be at least 8 characters, and contain at least one upper case letter, one lower case letter, and one number.",
            attributes: [
                .font: UIFont.TravDemiSmall(),
                .foregroundColor: UIColor.TravRed()
            ])
        if let txt = passwordField.text {
                isPasswordValid = true
                attrStr.addAttributes(setupAttributeColor(if: (txt.count >= 8)),
                                      range: findRange(in: attrStr.string, for: "at least 8 characters"))
                attrStr.addAttributes(setupAttributeColor(if: (txt.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil)),
                                      range: findRange(in: attrStr.string, for: "one upper case letter"))
                attrStr.addAttributes(setupAttributeColor(if: (txt.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil)),
                                      range: findRange(in: attrStr.string, for: "one lower case letter"))
                attrStr.addAttributes(setupAttributeColor(if: (txt.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil)),
                                      range: findRange(in: attrStr.string, for: "one number"))
            } else {
                isPasswordValid = false
            }
        
        validationLabel.attributedText = attrStr
    }


    // MARK: - In-Place Validation Helpers
    func setupAttributeColor(if isValid: Bool) -> [NSAttributedString.Key: Any] {
        if isValid {
            return [NSAttributedString.Key.foregroundColor: UIColor.TravRed()]
        } else {
            isPasswordValid = false
            return [NSAttributedString.Key.foregroundColor: UIColor.gray]
        }
    }

    func findRange(in baseString: String, for substring: String) -> NSRange {
        if let range = baseString.localizedStandardRange(of: substring) {
            let startIndex = baseString.distance(from: baseString.startIndex, to: range.lowerBound)
            let length = substring.count
            return NSMakeRange(startIndex, length)
        } else {
            print("Range does not exist in the base string.")
            return NSMakeRange(0, 0)
        }
    }

    // MARK: - Validation Methods
    func validateEmail(email: String?) -> String? {
        guard let trimmedText = email?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        
        let range = NSMakeRange(0, NSString(string: trimmedText).length)
        let allMatches = dataDetector.matches(in: trimmedText,
                                              options: [],
                                              range: range)
        
        if allMatches.count == 1,
            allMatches.first?.url?.absoluteString.contains("mailto:") == true {
            return trimmedText
        } else {
            Alerts.showErrorBanner("Please choose a valid email")
            return nil
        }
    }

    func validatePassword(password: String?) -> String? {

        var errorMsg = "Password requires at least "
        
        if let txt = passwordField.text {
            if (txt.rangeOfCharacter(from: CharacterSet.uppercaseLetters) == nil) {
                errorMsg += "one upper case letter"
            }
            if (txt.rangeOfCharacter(from: CharacterSet.lowercaseLetters) == nil) {
                errorMsg += ", one lower case letter"
            }
            if (txt.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
                errorMsg += ", one number"
            }
            if txt.count < 8 {
                errorMsg += ", and eight characters"
            }
        }
        
        if isPasswordValid {
            return password!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            Alerts.showErrorBanner(errorMsg)
            return nil
        }
        
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


