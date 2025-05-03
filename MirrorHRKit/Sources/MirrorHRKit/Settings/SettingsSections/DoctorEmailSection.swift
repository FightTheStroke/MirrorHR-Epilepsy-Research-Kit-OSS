//
//  DoctorEmailSection.swift
//  
//
//  Created by Roberto D’Angelo on 16/07/22.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.

import Foundation
import SwiftUI
import SharedPkg

struct DoctorEmailSettingsView: View {
    @ObservedObject var settings = ProfileGenericSettings.shared
    @State private var isEditing: Bool = false
    let fieldName = "doctorsEmailString".local()
    
    var body: some View {
        VStack {
            HStack {
                Text(fieldName)
                Spacer()
                Text(settings.doctorEmail)
                    .font(.body.bold())
                if isEditing {
                    Button {
                        UIApplication.shared.endEditing()
                        isEditing = false
                    } label: {
                        Image(systemName: "checkmark.circle")
                            .font(.body.bold())
                    }
                } else {
                    Button {
                        isEditing = true
                    } label: {
                        Image(systemName: chevronDown)
                            .font(.body.bold())
                    }
                }
            }
            if isEditing {
                MyTextField(fieldName: fieldName, bindingString: $settings.doctorEmail, isMandatory: false, split2Rows: false, showFieldName: false, textAlignment: .center, frameWidth: nil)
            }
        }
    }
}
