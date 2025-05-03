//
//  RequestReviewSection.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 17/10/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import StoreKit
import SwiftUI
import SharedPkg

extension SettingsView {
    var askForRateView: some View {
        HStack {
            Button {
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            } label: {
                Label("requestReviewMessage".local(), systemImage: "star.fill" )
                    .labelStyle(ColorfulIconLabelStyle(color: stefiGreen, size: size))
            }
            .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}
