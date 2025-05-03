//
//  OnboardingPickerForm.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 11/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

struct OnboardingPickerForm: View {
    @State var currentValue: Int

    let conditionText: String
    let options: [Int]
    let onChange: (_ index: Int) -> Void

    var body: some View {
        VStack {
            Divider()
            Text(conditionText).font(.headline)
            Picker(selection: $currentValue, label: Text(conditionText)) {
                ForEach(0 ..< options.count, id: \.self) { index in
                    Text("\(options[index]) BPM")
                }
            }
            .pickerStyle(WheelPickerStyle())
            .onChange(of: $currentValue.wrappedValue, perform: onChange)
            .padding(EdgeInsets(top: -10, leading: 0, bottom: -10, trailing: 0))
        }
    }
}
