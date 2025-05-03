//
//  KeyAlarmSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension KeySettingsView {
    var alarmSection: SettingsSection {
        SettingsSection(
            id: "Alarm",
            header: alarmSettingsMsg,
            image: "speaker.wave.2",
            rows: [
                .custom(
                    name: "whenBpmLowerThanMsg".local(),
                    AnyView(SettingsComponents.whenBPMLowerView(parameter: $viewModel.keyFlowThresholds.alarmMin))
                ),
                .custom(
                    name: "whenBpmHigherThanMsg".local(),
                    AnyView(SettingsComponents.whenBPMHigherView(parameter: $viewModel.keyFlowThresholds.alarmMax))
                ),
                .custom(name: "alarmSoundVolumeMsg".local(),
                        AnyView(AlarmSoundVolumeView(parameter: $viewModel.soundOptions.alarmSoundVolume)))
            ],
            footer: alarmSettingsFooterMsg,
            isEnabled: viewModel.dataSourceManager.dataSource.canSetKeySettings,
            foregroundColor: Color(FlowStages.alarm.chartColor)
        )
    }
}
