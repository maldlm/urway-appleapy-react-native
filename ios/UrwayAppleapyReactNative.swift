//
//  RCTapplepay.swift
//  DApplePay
//
//  Created by Urway-144 on 30/11/2022.
//

import Foundation
import UIKit
import PassKit
import React

typealias PaymentCompletionHandler = (Bool) -> Void


@objc(Applepay)
class Applepay : NSObject {

  var paymentController: PKPaymentAuthorizationController?
  var paymentSummaryItems = [PKPaymentSummaryItem]()
  var paymentStatus = PKPaymentAuthorizationStatus.failure
  var completionHandler: PaymentCompletionHandler!
  var appleToken : PKPayment?
  var merchantIdentfier : String?
  var label : String?
  var allowedNetworks: [String]?
  var response :RCTResponseSenderBlock?
  var result : PKPaymentAuthorizationResult?
  var amount : String?
  var err : PKPaymentAuthorizationResult?
  var paymentAuthorizationCompletion: ((PKPaymentAuthorizationResult) -> Void)?





  @available(iOS 12.1.1, *)
  static let supportedNetworks: [PKPaymentNetwork] = [
      .amex,
      .discover,
      .masterCard,
      .visa,
      .mada,
      .quicPay
  ]
  static let supportedNetworksWithoutMada: [PKPaymentNetwork] = [
      .amex,
      .discover,
      .masterCard,
      .visa,
      .quicPay
  ]
    
  @objc
    func createApplePayToken(_ merchantIdentfier:String,amount:String,label:String,allowedNetworks:[String], callback:@escaping RCTResponseSenderBlock) -> Void {

    let deviceCanMakePayment = Applepay.applePayStatus();

    if !deviceCanMakePayment {

      callback(["this device dose not support applepay"]);
    }
    else {
      self.merchantIdentfier = merchantIdentfier;
      self.label = label;
      self.allowedNetworks = allowedNetworks;
      self.response = callback;
      self.amount = amount

        self.startPayment(allowedNetworks: allowedNetworks)
    }
  }
  @objc
    func dismissApplePaySheet() -> Void {
        if let paymentController = paymentController {
            paymentController.dismiss(completion: nil)
        }
    }

  @objc func finalizePayment(_ success: Bool, callback: @escaping RCTResponseSenderBlock) {
    let status: PKPaymentAuthorizationStatus = success ? .success : .failure
    let paymentResult = PKPaymentAuthorizationResult(status: status, errors: nil)

    // Correctly use `paymentAuthorizationCompletion` with the expected `PKPaymentAuthorizationResult`
    if let completion = self.paymentAuthorizationCompletion {
        completion(paymentResult) // Call the completion with `PKPaymentAuthorizationResult`
        self.paymentAuthorizationCompletion = nil // Reset for future transactions
        callback([NSNull(), "Payment finalized successfully"])
    } else {
        // Error handling if the completion handler is not set
        callback(["Error: Payment authorization completion handler not found", NSNull()])
    }
  }

  func startPayment(allowedNetworks:[String]) -> Void{
    let total = PKPaymentSummaryItem(label: self.label!, amount: NSDecimalNumber(string: self.amount!), type: .final)
      paymentSummaryItems = [total]
      let paymentRequest = PKPaymentRequest()
      paymentRequest.paymentSummaryItems = paymentSummaryItems
      paymentRequest.merchantIdentifier = self.merchantIdentfier!
      paymentRequest.merchantCapabilities = .capability3DS
      paymentRequest.countryCode = "SA"
      paymentRequest.currencyCode = "SAR"
        if #available(iOS 12.1.1, *) {
          paymentRequest.supportedNetworks = Applepay.supportedNetworks.filter { allowedNetworks.contains($0.rawValue) }
      } else {
          paymentRequest.supportedNetworks = Applepay.supportedNetworksWithoutMada.filter { allowedNetworks.contains($0.rawValue) }
      }

      paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
      paymentController?.delegate = self
      paymentController?.present(completion: { (presented: Bool) in
          if presented {
              debugPrint("Presented payment controller")
          } else {
            self.response!(["apple pay is not set up correctly: [ no cards , merchantIdentifier]"])
            debugPrint("Failed to present payment controller")

          }
      })
    }

  class func applePayStatus() -> (Bool) {
      return (PKPaymentAuthorizationController.canMakePayments())

  }
  func getToken (token:PKPayment) -> PKPayment {
    return token
  }

  public static func generatePaymentKey(payment: PKPayment) -> NSString {

      let data12 = payment.token.paymentData
      let method = payment.token.paymentMethod

      if let jsonString = NSString(data: data12, encoding: .zero) {

          let prefixString: NSString = "\("{ \"paymentData\"  : ")" as NSString
          let finalSuffixString: NSString = """
              , "paymentMethod": {
              "displayName": "\(method.displayName ?? "")",
              "network": "\(method.network?.rawValue ?? "")",
              "type": "debit"
              },
              "transactionIdentifier": "\(payment.token.transactionIdentifier)" }
              """ as NSString

          let combinderString: NSString = "\(prefixString) \(jsonString) \(finalSuffixString)" as NSString
          print("apple pay token is equal to : \(combinderString)")
          return combinderString
      }

      return ""
  }

  @objc
    static func requiresMainQueueSetup() -> Bool {
    return false;
  }

}

extension Applepay: PKPaymentAuthorizationControllerDelegate {

    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Store the completion handler
        self.paymentAuthorizationCompletion = completion
        
        // Convert the payment to a token and pass to React Native
        let token = Applepay.generatePaymentKey(payment: payment)
        self.response!([NSNull(), token])
        
        // Do not call completion here
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
      print("sheet closed")
      if (self.paymentStatus == .success) {
      } else {
        controller.dismiss(completion: userDismiss)
      }
    }

    func userDismiss() {
        self.response!(["dismiss"])
    }
}
