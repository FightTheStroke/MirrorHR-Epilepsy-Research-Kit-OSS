//
//  KidWeightInput.swift
//  
//
//  Created by Roberto D’Angelo on 30/12/21.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import SharedPkg

struct InputKidWeightView: View {
    var showUnit: Bool
    @ObservedObject var settings = ProfileGenericSettings.shared
    @State private var unit: MeasurementsUnit = ProfileGenericSettings.shared.measurementsUnit
    @State private var kidWeight: Double = ProfileGenericSettings.shared.kidWeight
    
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .decimal
        return nf
    }()
    
    @State private var isEditing: Bool = false
    
    var body: some View {
        HStack {
            Text("kidWeightString".local() + ":")
            TextField("", value: $kidWeight, formatter: numberFormatter, onEditingChanged: { (editingChanged) in
                if editingChanged {
                    isEditing = true
                } else {
                    isEditing = false
                }
            })
            .font(isEditing ? .body : .body.bold())
                .multilineTextAlignment(.trailing)
                .keyboardType(.decimalPad)
                .onTapGesture(perform: UIApplication.shared.endEditing)
            
            if showUnit {
                Text(unit.weightUnit)
                Menu {
                    buildMenu()
                } label: {
                    Image(systemName: chevronDown)
                        .font(.body.bold())
                }
            }
            
            if isEditing {
                Button {
                    UIApplication.shared.endEditing()
                    settings.kidWeight = kidWeight
                    isEditing = false
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.body.bold())
                }
            }
        }
        .padding(showUnit ? [] : .horizontal)
    }
    
    func buildMenu() -> some View {
        ForEach(MeasurementsUnit.allCases, id: \.self) { unit in
            Button(action: {
                self.unit = unit
                ProfileGenericSettings.shared.measurementsUnit = unit
            }, label: {
                Text(unit.weightUnit)
            })
        }
    }
}

struct InputKidDateOfBirth: View {
    @ObservedObject var settings = ProfileGenericSettings.shared
    
    var body: some View {
        HStack {
            Text("kidDateOfBirthString".local() + ":")
            Spacer()
            DatePicker(selection: $settings.kidBirthDate, in: ...Date(), displayedComponents: [.date]) {
                Text("")
            }
            .labelsHidden()
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}
