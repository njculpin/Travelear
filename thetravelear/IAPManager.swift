//
//  StoreHelper.swift
//  Travelear
//
//  Created by Nick Culpin on 1/6/20.
//  Copyright © 2020 thetravelear. All rights reserved.
//

import StoreKit
import FirebaseFunctions
import Network
import FirebaseCrashlytics

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
  static let IAPManagerPurchaseNotification = Notification.Name("IAPManagerPurchaseNotification")
}

open class IAPManager: NSObject  {
    
    let monitor = NWPathMonitor()
    static let shared = IAPManager()
  
    private var promotedPayment: SKPayment?
    private let productIdentifiers: Set<ProductIdentifier> = [IAProducts.one, IAProducts.six, IAProducts.twelve]
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    
    lazy var functions = Functions.functions()

    var hasPromotedPayment: Bool {
        return promotedPayment != .none
    }
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API

extension IAPManager {
      
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    public func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }

    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    public func verify(){
        if Internet.sharedInstance.isConnectedToNetwork() == true {
            if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
                FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
                do {
                    let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                    let receiptString = receiptData.base64EncodedString(options: [])
                                        
                    functions.httpsCallable("validateReceipt").call(["receipt": receiptString]) { (result, error) in
                      
                        
                        if let error = error as NSError? {
                        if error.domain == FunctionsErrorDomain {
                        }
                      }
                        
                        do {
                            let jsonData = try! JSONSerialization.data(withJSONObject: result!.data)
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
                            if let object = json as? [String: Any] {
                                if let latest_receipt_info = object["latest_receipt_info"] as? NSArray {
                                    if let items = latest_receipt_info[0] as? [String:Any] {
                                        let product_id = items["product_id"] as? String
                                        let expires_date = Double(items["expires_date_ms"] as! String)
                                        let purchase_date = Double(items["purchase_date_ms"] as! String)
                                        let subscription_period_start = Date(timeIntervalSince1970: (purchase_date! / 1000.0))
                                        let subscription_period_end = Date(timeIntervalSince1970: (expires_date! / 1000.0))
                                        
                                        
                                        if subscription_period_end <= Date()  {
                                            NotificationCenter.default.post(name: .PurchaseNotification, object: true)
                                            UserDefaults.standard.setValue(true, forKey: "isPurchased")
                                        } else {
                                            NotificationCenter.default.post(name: .PurchaseNotification, object: false)
                                            UserDefaults.standard.setValue(false, forKey: "isPurchased")
                                        }
                                        
                                        API.savePurchase(identifier: product_id, subscription_period_start: subscription_period_start, subscription_period_end: subscription_period_end)
                                    }
                                }
                                
                            }

                        } catch {
                            print(error.localizedDescription)
                            Crashlytics.crashlytics().record(error: error)
                        }
                    }
                }
                catch {
                    print("Couldn't read receipt data with error: " + error.localizedDescription)
                    Crashlytics.crashlytics().record(error: error)
                }
                
            }
        } else {
            print("internet failed")
        }
        
    }
    
}

// MARK: - SKProductsRequestDelegate

extension IAPManager: SKProductsRequestDelegate {

  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    let products = response.products
    productsRequestCompletionHandler?(true, products)
    clearRequestAndHandler()
  }

  public func request(_ request: SKRequest, didFailWithError error: Error) {
    productsRequestCompletionHandler?(false, nil)
    clearRequestAndHandler()
  }

  private func clearRequestAndHandler() {
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver

extension IAPManager: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        promotedPayment = payment
        return false
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
          switch (transaction.transactionState) {
          case .purchased:
            complete(transaction: transaction)
            break
          case .failed:
            fail(transaction: transaction)
            break
          case .restored:
            restore(transaction: transaction)
            break
          case .deferred:
            break
          case .purchasing:
            break
          @unknown default:
            break
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        NotificationCenter.default.post(name: .PurchaseNotification, object: true)
        SKPaymentQueue.default().finishTransaction(transaction)
        IAPManager.shared.verify()
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
        IAPManager.shared.verify()
    }

    private func fail(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError?,
          let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
            Alerts.showErrorBanner(localizedDescription)
          }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPManagerPurchaseNotification, object: identifier)
    }

}
