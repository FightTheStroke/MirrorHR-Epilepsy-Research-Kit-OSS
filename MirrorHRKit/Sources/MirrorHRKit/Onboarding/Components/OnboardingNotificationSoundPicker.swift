//
//  OnboardingNotificationSoundPicker.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

struct OnboardingNotificationSoundPicker: View {
    let formTitle: String
    @Binding var selectionBinding: Int
    let options: [String]
    let buttonText: String
    let buttonAction: () -> Void

    var body: some View {
        VStack {
            Picker(selection: $selectionBinding, label: Text(formTitle)) {
                ForEach(0 ..< options.count, id: \.self) {
                    Text(options[$0])
                }
            }.pickerStyle(WheelPickerStyle())
            Button(action: buttonAction) {
                Text(buttonText)
            }
            Divider()
        }
    }
}
