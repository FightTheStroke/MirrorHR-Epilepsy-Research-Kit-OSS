//
//  StreamingSection.swift
//
//  Copyright © 2021 FightTheStroke Foundation. All rights reserved.
//  Created by Roberto D’Angelo on 02/09/22.
//

import SwiftUI
import SharedPkg
import MirrorHRTelemetryPackage

private let streamingSectionFooterIntro: String = "StreamingSectionFooterIntro".local()
public let streamingSectionAlertMsg: String = "StreamingSectionAlertMsg".local()
private let streamingSectionFooterMsg = streamingSectionFooterIntro + streamingSectionAlertMsg

extension SettingsView {
    var mainDataSourceSection: SettingsSection {
        SettingsSection(
            id: "mainDataSourceSection",
            header: "HealthDataSourceSettingsView".local(),
            image: "heart",
            rows: [
                .custom(name: "DataSourcePicker", AnyView(DataSourcePickerView()), isEnabled: true)
            ],
            footer: "",
            foregroundColor: stefiGreen
        )
    }
}
