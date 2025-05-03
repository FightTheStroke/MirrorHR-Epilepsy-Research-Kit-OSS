//
//  DonateView.swift
//
//
//  Created by Roberto D’Angelo on 18/02/24.
//

import Foundation
import SwiftUI
import Stripe
import SharedPkg
import RoberdanSecretsPackage

public struct DonateView: View {
    @ObservedObject var applePayModel: ApplePayModel = .shared
    @State private var selectedAmount: Double = 10.0
    let size: CGFloat = 45
    // Define your donation amounts here
    let donationAmounts: [Double] = [5.0, 10.0, 25.0]
    
    public init() {}
    
    public var body: some View {
        VStack (alignment: .leading) {
            Label {
                Text("AppreciateDonationsMsg".localized())
                    .font(.body)
            } icon: {
                Image(systemName: "heart.fill")
                    .imageScale(.medium)
                    .foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 7 ).frame(width: 28 , height: 28).foregroundColor(.purple))
            }

            Picker("", selection: $selectedAmount) {
                ForEach(donationAmounts, id: \.self) { amount in
                    Text("\(Int(amount)) €").tag(amount)
                        .font(.title)
                }
            }
            .pickerStyle(.segmented) // Use .wheel or .menu depending on your preference
            PaymentButton() {
                submitDonation()
            }
           
            if let paymentStatus = applePayModel.paymentStatus {
                // Display payment status
                switch paymentStatus {
                case .success:
                    Label("ThankYouForDonationMsg".localized(), systemImage: "heart.fill")
                        .foregroundColor(.green)
                        .fontWeight(.bold)
                case .error:
                    Label("DonationFailedMsg".localized(), systemImage: "xmark.octagon.fill")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                case .userCancellation:
                    Label("DonationCancelledMsg".localized(), systemImage: "xmark.octagon.fill")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                @unknown default:
                    Label("UnknownDonationStatusMsg".localized(), systemImage: "xmark.octagon.fill")
                        .foregroundColor(.red)
                        .fontWeight(.bold)
                }
            }
        }.padding(.vertical)
    }
    
    private func submitDonation() {
        mainDebugger.append("Donation of \(selectedAmount)€ selected at \(Date().toStdString())", .event, sourceModule: "MyStripeApplePayPackage - DonateView")
        applePayModel.preparePaymentIntent(amount: selectedAmount)
    }
}

struct DonateViewPreview: PreviewProvider {
    static var previews: some View {
        DonateView()
    }
}
