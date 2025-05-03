//
//  OnboardingButtonForm.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

struct OnboardingButtonForm: View {
    let title: String
    let icon: String
    let iconBtn: String
    let btnTitle: String
    let action: () -> Void
    let topPadding: Bool

    var body: some View {
        if topPadding {
            buttonForm
                .padding(.top)
        } else {
            buttonForm
        }
    }
    
    private var buttonForm: some View {
        HStack(alignment: .center) {
            Label(title, systemImage: icon)
                .font(.headline)
            Spacer()
            Button(action: action) {
                Label(btnTitle, systemImage: iconBtn)
            }
            .padding()
            .buttonStyle(.bordered)
        }
    }
}

