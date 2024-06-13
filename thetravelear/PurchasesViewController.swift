//
//  PurchasesViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 12/3/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit
import StoreKit
import Firebase

class PurchasesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    var cellID = "productID"
    var products: [SKProduct] = []
    
    lazy var popOverTitleLabel = TravelearLabel()
    lazy var cancelButton: UIButton = {
        let sb = UIButton()
        let image = UIImage(named: "min-button") as UIImage?
        sb.setImage(image, for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        return sb
    }()
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.spacing = 0
        return stack
    }()
    
    lazy var featureView = FeatureView()
    
    lazy var productsTableView : UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(ProductCell.self, forCellReuseIdentifier: cellID)
        return tv
    }()
    
    lazy var restoreButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Restore Purchases", for: .normal)
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.contentHorizontalAlignment = .left
        sb.backgroundColor = UIColor.white
        sb.titleLabel?.font = UIFont.TravDemiSmall()
        sb.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
        return sb
    }()
    
    lazy var termsButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Terms of Service", for: .normal)
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.contentHorizontalAlignment = .left
        sb.backgroundColor = UIColor.white
        sb.titleLabel?.font = UIFont.TravDemiSmall()
        sb.addTarget(self, action: #selector(termsView), for: .touchUpInside)
        return sb
    }()
    
    lazy var privacyButton: UIButton = {
        let sb = UIButton()
        sb.setTitle("Privacy Policy", for: .normal)
        sb.setTitleColor(UIColor.black, for: .normal)
        sb.contentHorizontalAlignment = .left
        sb.backgroundColor = UIColor.white
        sb.titleLabel?.font = UIFont.TravDemiSmall()
        sb.addTarget(self, action: #selector(privacyView), for: .touchUpInside)
        return sb
    }()
    
    lazy var termsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.white
    view.addSubview(stackView)
    view.addSubview(featureView)
    view.addSubview(productsTableView)
    view.addSubview(termsStackView)
    stackView.addArrangedSubview(popOverTitleLabel)
    stackView.addArrangedSubview(cancelButton)
    termsStackView.addArrangedSubview(restoreButton)
    termsStackView.addArrangedSubview(privacyButton)
    termsStackView.addArrangedSubview(termsButton)
    
    stackView.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    popOverTitleLabel.heightAnchor.constraint(equalToConstant: 44).isActive = true
    cancelButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    cancelButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
    
    featureView.anchor(stackView.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    
    productsTableView.anchor(featureView.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 300)
    
    termsStackView.anchor(productsTableView.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 16, leftConstant: 16, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    
    popOverTitleLabel.font = UIFont.TravTitle()
    popOverTitleLabel.text = "Shop"
    
    reload()
    
    let defaults = UserDefaults.standard
    if defaults.isLoggedIn() != true {
        let controller = LoginViewController()
        controller.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        controller.popoverPresentationController?.delegate = self
        self.present(controller, animated:true, completion:nil)
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(PurchasesViewController.handlePurchaseNotification(_:)),
                                           name: .IAPManagerPurchaseNotification,
                                           object: nil)
  }
    
    @objc func termsView(){
        if let url = URL(string: AppConstants.termsURL) {
            UIApplication.shared.open(url)
        }
    }
    
    @objc func privacyView(){
        if let url = URL(string: AppConstants.privacyURL) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: PRODUCTS
    @objc func reload() {
     products = []
     productsTableView.reloadData()
     IAPManager.shared.requestProducts{ [weak self] success, products in
        guard let self = self else { return }
        if success {
          self.products = products!
            DispatchQueue.main.async {
                self.productsTableView.reloadData()
            }
        }
      }
        
    }

    @objc func restorePurchases(){
        IAPManager.shared.restorePurchases()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ProductCell
        let product = products[(indexPath as NSIndexPath).row]
        cell.product = product
        cell.buyButtonHandler = { product in
            IAPManager.shared.buyProduct(product)
        }
        
        cell.selectionStyle = .none
        
      return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = products[(indexPath as NSIndexPath).row]
        IAPManager.shared.buyProduct(product)
    }
    
    @objc func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String, let index = products.firstIndex(where: { product -> Bool in product.productIdentifier == productID }) else { return }
        productsTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        self.dismiss(animated: true, completion: nil)
    }
    
}
