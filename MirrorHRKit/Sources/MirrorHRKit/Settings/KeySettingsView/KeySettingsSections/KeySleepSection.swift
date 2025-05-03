//
//  KeySleepSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension KeySettingsView {
    var sleepSection: SettingsSection {
        SettingsSection(
            id: "KeySleep",
            header: sleepSettingsTitleMsg.uppercased(),
            image: "bed.double",
            rows: [
                .custom(name: "deepSleepMax", AnyView(KeySettingsDeepSleepView())),
                .custom(name: "lightSleepMax", AnyView(KeySettingsLightSleepView()))
            ],
            footer: sleepSettingsFooterMsg,
            isEnabled: viewModel.dataSourceManager.dataSource.canSetKeySettings,
            foregroundColor: Color(FlowStages.deepSleep.chartColor)
        )
    }
}

struct KeySettingsDeepSleepView: View {
    @ObservedObject var keyFlowThresholds: KeyFlowThresholds = .shared
    var body: some View {
        HStack {
            Picker(selection: $keyFlowThresholds.deepSleepMax) {
                ForEach(10 ..< 200, id: \.self) { index in
                    Text("\(index)")
                }
            } label: {
                Text("deepSleepMaxBpmMsg".local())
            }
        }
    }
}

struct KeySettingsLightSleepView: View {
    @ObservedObject var keyFlowThresholds: KeyFlowThresholds = .shared
    var body: some View {
        HStack {
            Picker(selection: $keyFlowThresholds.lightSleepMax) {
                ForEach(10 ..< 200, id: \.self) { index in
                    Text("\(index)")
                }
            } label: {
                Text("lightSleepMaxBpmMsg".local())
            }
        }
    }
}
