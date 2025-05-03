//
//  ApplePayModel.swift
//  AcceptAPayment
//
//  Created by Roberto D'Angelo on 2/19/21.
//

import Foundation
import Stripe
import RoberdanToolBox
import RoberdanSecretsPackage
import SharedPkg
import PassKit

class ApplePayModel : NSObject, ObservableObject, STPApplePayContextDelegate {
    static var shared: ApplePayModel = ApplePayModel()
    @Published var paymentStatus: STPPaymentStatus?
    @Published var lastPaymentError: Error?
    
    private var paymentIntentParams: STPPaymentIntentParams?

    let paymentMethodType: String = "card"
    let currency: String = RoberdanSecretsPackage.defaultCurrency
    var clientSecret: String?

    private override init() {
        super.init()
        StripeAPI.defaultPublishableKey = RoberdanSecretsPackage.stripePublishableKey
        mainDebugger.append("Stripe API initialized at \(Date().toStdString())", .justALog, sourceModule: "MyStripeApplePackage - ApplePayModel")
    }
    
    func preparePaymentIntent(amount: Double) {
        mainDebugger.append("Prepare payment intent for \(amount) at \(Date().toStdString())", .justALog, sourceModule: "MyStripeApplePackage - BackEndModel")
        
        guard let url = URL(string: RoberdanSecretsPackage.backendStripeUrl + "create-payment-intent") else {
            mainDebugger.append("can't get create payment intent url at \(Date().toStdString())", .error, sourceModule: "MyStripeApplePackage - BackEndModel")
            return
        }
        // Convert amount to the smallest currency unit (e.g., cents for USD)
        let amountInSmallestUnit = Int(amount * 100)
        
        // MARK: Fetch the PaymentIntent from the backend
        // Create a PaymentIntent by calling the server's po u endpoint.
        let json: [String: Any] = [
            "currency": currency,
            "amount": amountInSmallestUnit,
            "paymentMethodType": paymentMethodType
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                mainDebugger.append("Error: \(error?.localizedDescription ?? "Unknown error") at \(Date().toStdString())", .error, sourceModule: "MyStripeApplePackage - BackEndModel")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let clientSecret = json["clientSecret"] as? String {
                        DispatchQueue.main.async {
                            self.clientSecret = clientSecret
                            self.paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                            self.pay(clientSecret: clientSecret, amount: amount)
                        }
                    }
                } catch {
                    mainDebugger.append("Error parsing the response JSON: \(error) at \(Date().toStdString())", .error, sourceModule: "MyStripeApplePackage - BackEndModel")
                }
            } else {
                mainDebugger.append("Server responded with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0) at \(Date().toStdString())", .error, sourceModule: "MyStripeApplePackage - BackEndModel")
            }
        }
        
        task.resume()
    }
    
    func pay(clientSecret: String?, amount: Double) {
        self.clientSecret = clientSecret
        
        // Configure a payment request
        let pr = StripeAPI.paymentRequest(withMerchantIdentifier: RoberdanSecretsPackage.merchantIdentifier, country: RoberdanSecretsPackage.countryCode, currency: RoberdanSecretsPackage.defaultCurrency)

        // You'd generally want to configure at least `.emailAddress` here.
        pr.requiredBillingContactFields = [.emailAddress]

        // Build payment summary items
        pr.paymentSummaryItems = [
            PKPaymentSummaryItem(label: RoberdanSecretsPackage.donateToString, amount: NSDecimalNumber(value: amount)),
        ]

        // Present the Apple Pay Context:
        let applePayContext = STPApplePayContext(paymentRequest: pr, delegate: self)
        applePayContext?.presentApplePay()
    }

    public func applePayContext(_ context: STPApplePayContext, didCreatePaymentMethod paymentMethod: STPPaymentMethod, paymentInformation: PKPayment, completion: @escaping STPIntentClientSecretCompletionBlock) {
        // Confirm the PaymentIntent
        if let clientSecret = self.clientSecret {
            // Call the completion block with the PaymentIntent's client secret.
            completion(clientSecret, nil)
        } else {
            completion(nil, NSError(domain: "ApplePayModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "Client secret not available"]))
        }
    }

    public func applePayContext(_ context: STPApplePayContext, didCompleteWith status: STPPaymentStatus, error: Error?) {
        // When the payment is complete, display the status.
        DispatchQueue.main.async {
            self.paymentStatus = status
            self.lastPaymentError = error
        }
        mainDebugger.append("ApplePay returned status as \(status) and error as \(String(describing: error?.localizedDescription)) at \(Date().toStdString())", .event, sourceModule: "MyStripeApplePackage - ApplePayModel")
    }
}
