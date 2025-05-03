//
//  AlarmSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension SettingsView {
    var alarmSection: SettingsSection {
        SettingsSection(
            id: "Alarm",
            header: "alarmString".local(),
            image: "speaker.wave.2",
            rows: [
                .custom(
                    name: "whenBpmLowerThanMsg".local(),
                    AnyView(SettingsComponents.whenBPMLowerView(parameter: $viewModel.keyFlowThresholds.alarmMin)),
                    isEnabled: viewModel.settings.appleWatchEnabled
                ),
                .custom(
                    name: "whenBpmHigherThanMsg".local(),
                    AnyView(SettingsComponents.whenBPMHigherView(parameter: $viewModel.keyFlowThresholds.alarmMax)),
                    isEnabled: viewModel.settings.appleWatchEnabled
                ),
                .custom(
                    name: triageDeltaTimeBeforeFireAlarmMsg,
                    AnyView(SettingsComponents.timeBufferAlarmView(parameter: $viewModel.keyFlowThresholds.triageDeltaTimeBeforeFireAlarm)),
                    isEnabled: viewModel.settings.appleWatchEnabled
                ),
                .custom(name: "alarmSoundStyleMsg".local(), AnyView(soundPickerView),
                        isEnabled: viewModel.settings.appleWatchEnabled),
                .custom(name: "alarmSoundVolumeMsg".local(),
                        AnyView(AlarmSoundVolumeView(
                        parameter: self.$viewModel.sounds.alarmSoundVolume)
                        ),
                        isEnabled: viewModel.settings.appleWatchEnabled),
                .custom(name: "testAlarmSoundBgkTitleMsg".local(), AnyView(testNotificationView),
                        isEnabled: viewModel.settings.appleWatchEnabled)
            ],
            footer: watchAvailableToggleCaptionString,
            isEnabled: true,
            foregroundColor: Color(FlowStages.alarm.chartColor)
        )
    }

    var soundPickerView: some View {
        SoundsPickerView(
            parameter: self.$viewModel.sounds.alarmSoundIndex,
            optionsArray: self.viewModel.sounds.alarmSoundOptions,
            labelText: "alarmSoundStyleMsg".local()
        )
    }
    
    var testNotificationView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("testAlarmSoundBgkTitleMsg".local())
                Text("rememberDuplicateNotificationsString".local())
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button(action: self.viewModel.testAlarm) {
                Image(systemName: "speaker.wave.3")
                    .font(.headline)
            }
        }
    }
}

struct EmergencyPhoneCallView: View {
    @ObservedObject var settings = ProfileGenericSettings.shared
    @State private var isEditing: Bool = false
    let fieldName = "emergencyContactTitleMsg".local()
    
    var body: some View {
        VStack {
            HStack {
                Text(fieldName)
                Spacer()
                Text(settings.emergencyNumber)
                    .font(.body.bold()).foregroundColor(.accentColor)
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
                MyTextField(fieldName: fieldName, bindingString: $settings.emergencyNumber, isMandatory: false, split2Rows: false, showFieldName: false, textAlignment: .center, frameWidth: nil)
            }
        }
    }
}
