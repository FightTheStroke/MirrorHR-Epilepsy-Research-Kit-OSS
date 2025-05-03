//
//  OnboardingTextField.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct OnboardingTextField: View {
    let header: String
    @Binding var binding: String

    var body: some View {
        TextField(header, text: $binding)
            .font(.title2)
            .multilineTextAlignment(.center)
    }
}

struct OnboardingDoubleField: View {
    let header: String
    @Binding var binding: Double
    @State private var bindingText: String = "1"

    var body: some View {
        VStack {
            Text(header)
            TextField(header, text: $bindingText)
                .font(.title2)
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .onReceive(Just(bindingText)) { newValue in
                                let filtered = newValue.filter { "0123456789.,".contains($0) }
                                if filtered != newValue {
                                    self.bindingText = filtered
                                }
                    binding = Double(newValue) ?? 1.0
                }
        }
    }
}
