//
//  ProductCell.swift
//  Travelear
//
//  Created by Nick Culpin on 1/6/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import UIKit
import StoreKit

class ProductCell: UITableViewCell {

    var titleLabel = TravelearLabel()
    var priceLabel = TravelearLabel()
    var buyLabel = TravelearLabel()
    let productImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.vertical
        stack.spacing = 2
        return stack
    }()
    
    
    var buyButtonHandler: ((_ product: SKProduct) -> Void)?
    
    static let priceFormatter: NumberFormatter = {
      let formatter = NumberFormatter()
      formatter.formatterBehavior = .behavior10_4
      formatter.numberStyle = .currency
      return formatter
    }()
    
    var product: SKProduct?  {
        didSet {
            self.updateUI()
            self.setNeedsLayout()
        }
    }
    
    
    func updateUI(){
        
        var number = String()
        var duration = String()
        
        switch product?.productIdentifier {
            case "XXX":
                productImageView.image = UIImage(imageLiteralResourceName: "World-1")
            case "XXX":
                productImageView.image = UIImage(imageLiteralResourceName: "World-6")
            case "XXX":
                productImageView.image = UIImage(imageLiteralResourceName: "World-12")
            default:
                break
        }
        
        switch product!.subscriptionPeriod?.numberOfUnits {
            case 1:
                number = "1"
            case 6:
                number = "6"
            case 12:
                number = "12"
            default:
                break
        }

        switch product!.subscriptionPeriod?.unit {
            case SKProduct.PeriodUnit(rawValue: 0):
                duration = "Day"
            case SKProduct.PeriodUnit(rawValue: 1):
                duration = "Week"
            case SKProduct.PeriodUnit(rawValue: 2):
                duration = "Month"
            case SKProduct.PeriodUnit(rawValue: 3):
                duration = "Year"
            default:
                break
        }
        
        titleLabel.text = product?.localizedDescription
        titleLabel.font = UIFont.TravDemiMedium()
        
        ProductCell.priceFormatter.locale = product?.priceLocale
        priceLabel.text = "\(ProductCell.priceFormatter.string(from: product!.price)!) / \(number) \(duration)"
        
        buyLabel.textColor = UIColor.TravRed()
        buyLabel.font = UIFont.TravDemiSmall()
        buyLabel.text = "Buy Now"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    func setupViews(){
        addSubview(productImageView)
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(priceLabel)
        contentStackView.addArrangedSubview(buyLabel)
        productImageView.anchor(topAnchor, left: leftAnchor, bottom: bottomAnchor, right: contentStackView.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 100, heightConstant: 100)
        contentStackView.anchor(topAnchor, left: productImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 16, rightConstant: 16, widthConstant: 0, heightConstant: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
