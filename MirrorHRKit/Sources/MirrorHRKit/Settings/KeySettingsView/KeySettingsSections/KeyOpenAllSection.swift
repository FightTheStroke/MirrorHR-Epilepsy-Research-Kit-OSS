//
//  OpenAllSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//

import SwiftUI
import SharedPkg

extension KeySettingsView {
    var openAllSettingsSection: SettingsSection {
        SettingsSection(
            id: "OpenAll",
            header: nil,
            image: Tab.settings.image,
            rows: [
                .button(name: seeAllSettingsMsg, image: Tab.settings.image, action: viewModel.openAllSettings)
            ],
            footer: nil,
            foregroundColor: .gray
        )
    }
}
