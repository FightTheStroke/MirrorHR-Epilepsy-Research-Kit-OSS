//
//  ParamsPickerView.swift
//  Epilepsy Research Kit
//
//  Created by Roberto D’Angelo on 27/01/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

struct ParamsPickerViewToInt: View {
    @Binding var parameter: Int
    var optionsArray: [Int]
    var labelText: String
    var unitLabel: String // the metric unit
    
    init(parameter: Binding<Int>, optionsArray: [Int], labelText: String, unitLabel: String) {
        _parameter = parameter
        self.optionsArray = optionsArray
        self.labelText = labelText
        self.unitLabel = unitLabel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(labelText)
                Spacer()
                Menu {
                    Picker(labelText, selection: $parameter) {
                        ForEach(optionsArray, id: \.self) { value in
                            Text("\(value) \(unitLabel)")
                        }
                    }
                } label: {
                    HStack {
                        Text("\(parameter) \(String(unitLabel.prefix(3)))")
                        Image(systemName: chevronDown)
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}

struct SoundsPickerView: View {
    @Binding var parameter: Int
    var optionsArray: [String]
    var labelText: String
    
    init(parameter: Binding<Int>, optionsArray: [String], labelText: String) {
        _parameter = parameter
        self.optionsArray = optionsArray
        self.labelText = labelText
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Text(labelText)
                Spacer()
                Menu {
                    Picker(labelText, selection: $parameter) {
                        ForEach(optionsArray.indices, id: \.self) { index in
                            Text(optionsArray[index]).tag(index)
                        }
                    }
                } label: {
                    HStack {
                        Text(safeTitle)
                        Image(systemName: chevronDown)
                    }
                    .font(.body.bold())
                }
            }
        }
    }

    private var safeTitle: String {
        guard parameter >= 0, parameter < optionsArray.count else {
            return "Invalid Selection"
        }
        return optionsArray[parameter]
    }
}

struct AlarmSoundVolumeView: View {
    @Binding var parameter: Float

    var body: some View {
        let labelText: String = "alarmSoundVolumeMsg".local()
        let integerParameter = Int(parameter * 10) // Convert float to integer scale

        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(labelText)
                Image(systemName: "play.circle")
                    .onTapGesture {
                        dispatchMainEvent(.testSound(critical: true, delay: 0.01), "test notification button pressed")
                    }
                    .foregroundColor(.accentColor)
                Spacer()
                Menu {
                    Picker(labelText, selection: Binding(
                        get: { integerParameter },
                        set: { newValue in
                            parameter = Float(newValue) / 10.0
                        }
                    )) {
                        ForEach(alarmVolumeOptions, id: \.self) { value in
                            if value == alarmVolumeOptions.first {
                                Label("\(value)", systemImage: "minus")
                            } else if value == alarmVolumeOptions.last {
                                Label("\(value)", systemImage: "plus")
                            } else {
                                Text("\(value)")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("\(integerParameter)")
                        Image(systemName: chevronDown)
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}
