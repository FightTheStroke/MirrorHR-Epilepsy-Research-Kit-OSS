//
//  OnboardingAlarmSoundPicker.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

struct OnboardingAlarmSoundPicker: View {
    @Binding var selectionBinding: Int
    let formTitle: String
    let options: [String]
    let firstButtonText: String
    let firstButtonAction: () -> Void
    let secondButtonText: String
    /// The returned value controls whether we have to show the alert or not
    let secondButtonAction: () -> Bool
    let alert: Alert

    @State private var showingAlert = false
    var body: some View {
        VStack {
            Picker(selection: $selectionBinding, label: Text(formTitle)) {
                ForEach(0 ..< options.count, id: \.self) {
                    Text(options[$0])
                }
            }.pickerStyle(WheelPickerStyle())
            Divider()
            Button(action: firstButtonAction) {
                Text(firstButtonText)
                    .font(.body.bold())
            }
            Divider()
            let alertAction = {
                showingAlert = secondButtonAction()
            }
            Button(action: alertAction) {
                Text(secondButtonText)
                    .font(.body.bold())
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .alert(isPresented: $showingAlert) {
                        alert
                    }
            }
            Divider()
        }
    }
}
