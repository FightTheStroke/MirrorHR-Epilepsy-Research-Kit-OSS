//
//  KeyNotificationSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension KeySettingsView {
    var notificationSection: SettingsSection {
        SettingsSection(
            id: "Notification",
            header: notificationSettingsHeaderMsg,
            image: "bell.square",
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
                )
            ],
            footer: notificationFooterMsg,
            isEnabled: viewModel.dataSourceManager.dataSource.isNotificationSettingsEnabled,
            foregroundColor: Color(FlowStages.warning.chartColor)
        )
    }
}
