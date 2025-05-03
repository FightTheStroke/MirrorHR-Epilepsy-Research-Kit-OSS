//
//  SleepSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI

extension SettingsView {
    var sleepSection: SettingsSection {
        SettingsSection(
            id: "Sleep",
            header: "sleepSettingsTitleMsg".local(),
            image: "bed.double",
            rows: [
                .custom(name: "deepSleepMax", AnyView(KeySettingsDeepSleepView())),
                .custom(name: "lightSleepMax", AnyView(KeySettingsLightSleepView()))
            ],
            footer: "sleepSettingsFooterMsg".local(),
            isEnabled: viewModel.settings.appleWatchEnabled,
            foregroundColor: stefiPurple
        )
    }
}
