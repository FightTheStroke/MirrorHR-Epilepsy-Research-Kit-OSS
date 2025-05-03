//
//  KeyDebugSection.swift
//  Epilepsy Research Kit
//
//  Created by Riccardo Cipolleschi on 16/09/21.
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//
import SwiftUI
import SharedPkg

extension KeySettingsView {
    var debugSection: SettingsSection {
        SettingsSection(
            id: "Debug",
            header: debugModeMsg.uppercased(),
            image: "ant",
            rows: [
                .button(name: sampleChartDataMsg, image: "", action: viewModel.sampleChartDataPressed)
            ],
            foregroundColor: .gray
        )
    }
}
