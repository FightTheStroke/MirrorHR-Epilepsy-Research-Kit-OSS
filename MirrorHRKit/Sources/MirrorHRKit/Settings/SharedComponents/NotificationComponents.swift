//
//  NotificationComponents.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension SettingsComponents {
    static func notificationNotReceivingData(parameter: Binding<Int>) -> some View {
        ParamsPickerViewToInt(
            parameter: parameter,
            optionsArray: maxNoDataWarningOptions,
            labelText: noDataNotificationMsg,
            unitLabel: "secondsString".local()
        )
    }

    static func batteryPercentageView(parameter: Binding<Int>) -> some View {
        ParamsPickerViewToInt(
            parameter: parameter,
            optionsArray: batteryLevelWarningOptions,
            labelText: batteryLevelProfileMsg,
            unitLabel: "%"
        )
    }
}
