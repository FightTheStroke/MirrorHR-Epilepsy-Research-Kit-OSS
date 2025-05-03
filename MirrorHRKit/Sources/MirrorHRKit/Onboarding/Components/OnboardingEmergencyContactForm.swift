//
//  OnboardingEmergencyContactForm.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

struct OnboardingEmergencyContactForm: View {
    let textFieldHeader: String
    @Binding var textFieldBinding: String
    let buttonText: String

    var body: some View {
        VStack {
            Divider()
            OnboardingTextField(header: textFieldHeader, binding: $textFieldBinding)
            let btnAction = {
                guard
                    let number = URL(string: "tel://\($textFieldBinding.wrappedValue)")
                else {
                    return
                }
                UIApplication.shared.open(number)
            }
            Button(action: btnAction) {
                Text(buttonText)
                    .font(.body.bold())
            }
            Divider()
        }
    }
}
