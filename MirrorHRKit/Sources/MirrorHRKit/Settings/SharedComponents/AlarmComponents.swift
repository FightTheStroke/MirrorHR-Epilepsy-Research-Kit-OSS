//
//  AlarmComponents.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

enum SettingsComponents {
    static func whenBPMLowerView(parameter: Binding<Int>) -> some View {
        ParamsPickerViewToInt(
            parameter: parameter,
            optionsArray: alarmMinOptions,
            labelText: "whenBpmLowerThanMsg".local(),
            unitLabel: "BPM"
        )
    }

    static func whenBPMHigherView(parameter: Binding<Int>) -> some View {
        ParamsPickerViewToInt(
            parameter: parameter,
            optionsArray: alarmMaxOptions,
            labelText: "whenBpmHigherThanMsg".local(),
            unitLabel: "BPM"
        )
    }

    static func timeBufferAlarmView(parameter: Binding<Int>) -> some View {
        ParamsPickerViewToInt(
            parameter: parameter,
            optionsArray: triageTimeBufferOptions,
            labelText: triageDeltaTimeBeforeFireAlarmMsg,
            unitLabel: "secondsString".local()
        )
    }
}
