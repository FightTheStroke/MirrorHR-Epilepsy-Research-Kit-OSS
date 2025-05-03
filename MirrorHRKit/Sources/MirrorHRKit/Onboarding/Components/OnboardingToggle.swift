//
//  OnboardingToggle.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

struct OnboardingToggle: View {
    @Binding var binding: Bool
    let toggleText: String
    
    var body: some View {
        Toggle(isOn: $binding) {
            Text(toggleText)
                .padding()
        }
        .font(.body.bold())
        .padding(.horizontal)
    }
}
