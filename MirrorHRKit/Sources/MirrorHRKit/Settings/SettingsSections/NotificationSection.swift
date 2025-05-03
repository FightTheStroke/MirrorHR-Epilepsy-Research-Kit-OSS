//
//  NotificationSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension SettingsView {
    var notificationSection: SettingsSection {
        SettingsSection(
            id: "Notification",
            header: "LocalNotificationsHeaderMsg".local(),
            image: "bell.badge",
            rows: [
                .custom(
                    name: noDataNotificationMsg,
                    AnyView(SettingsComponents.notificationNotReceivingData(parameter: $viewModel.keyFlowThresholds.maxIntervalWithoutData)),
                    isEnabled: viewModel.keyFlowThresholds.shouldFireNoData
                ),
                .custom(
                    name: batteryLevelProfileMsg,
                    AnyView(SettingsComponents.batteryPercentageView(parameter: $viewModel.keyFlowThresholds.minBatteryLevelForNotification)),
                    isEnabled: viewModel.keyFlowThresholds.shouldFireLowBattery
                ),
                .custom(name: "notificationSoundStyleMsg".local(), AnyView(soundNotificationPicker)),
                .toggle(
                    name: parentalControlTitleMsg,
                    binding: $viewModel.settings.parentalControl,
                    foregroundColor: (viewModel.settings.appleWatchEnabled) ? .primary : .secondary,
                    caption: parentalControlProfileMsg
                ),
                .toggle(name: "NotifyRTEndTitleMsg".local(), binding: $viewModel.settings.notifyWhenRealtimeMonitorEnds, foregroundColor: viewModel.settings.appleWatchEnabled ? .primary : .secondary, caption: "NotifyRTEndCaptionMsg".local())
            ],
            footer: notificationSettingsFooterMsg + notificationFooterMsg + ".",
            isEnabled: viewModel.settings.appleWatchEnabled,
            foregroundColor: Color(FlowStages.warning.chartColor)
        )
    }

    var soundNotificationPicker: some View {
        SoundsPickerView(
            parameter: self.$viewModel.sounds.notificationSoundIndex,
            optionsArray: self.viewModel.sounds.notificationSoundOptions,
            labelText: "notificationSoundStyleMsg".local()
        )
    }
}
